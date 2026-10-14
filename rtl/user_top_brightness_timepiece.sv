// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  logic in_blank_hours;
  logic in_blank_minutes;
  logic in_blank_seconds;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(in_blank_hours),
      .blank_minutes(in_blank_minutes),
      .blank_seconds(in_blank_seconds)

  );

  localparam int CounterWidth = $clog2(CYCLES_PER_SECOND) + 1;

  logic [CounterWidth-1:0] pwm_count;

  mod_n_counter #(
      .N(CYCLES_PER_SECOND / 1000),
      .WIDTH(CounterWidth)
  ) u_pwm_count (
      .clk(clk),
      .rst('0),
      .enable('1),
      .count(pwm_count)
  );
  logic [1:0] pwm_bits;
  assign pwm_bits = sw[9:8];
  logic pwm_out;
  always_comb begin
    case (pwm_bits)
      2'b00:   pwm_out = (pwm_count >= CounterWidth'(CYCLES_PER_SECOND / 8000));
      2'b01:   pwm_out = (pwm_count >= CounterWidth'(CYCLES_PER_SECOND / 4000));
      2'b11:   pwm_out = (pwm_count >= CounterWidth'(CYCLES_PER_SECOND / 2000));
      2'b10:   pwm_out = '0;
      default: pwm_out = '0;

    endcase
  end

  assign blank_hours   = in_blank_hours | pwm_out;
  assign blank_minutes = in_blank_minutes | pwm_out;
  assign blank_seconds = in_blank_seconds | pwm_out;

endmodule
