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

module user_top_brightness_wrapper #(
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

  user_top #(
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

  logic pwm_50;
  logic pwm_25;
  logic pwm_125;
  logic pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 1000),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2000))
  ) u_pwm_50 (
      .clk(clk),
      .rst('0),
      .pwm_out(pwm_50)
  );

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 1000),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 4000))
  ) u_pwm_25 (
      .clk(clk),
      .rst('0),
      .pwm_out(pwm_25)
  );

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 1000),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 8000))
  ) u_pwm_125 (
      .clk(clk),
      .rst('0),
      .pwm_out(pwm_125)
  );

  always_comb begin
    case (sw)
      10'b0000000000: pwm_out = pwm_125;
      10'b0100000000: pwm_out = pwm_25;
      10'b1100000000: pwm_out = pwm_50;
      10'b1000000000: pwm_out = '1;
      default: pwm_out = '1;

    endcase
  end

  assign blank_hours   = in_blank_hours | ~pwm_out;
  assign blank_minutes = in_blank_minutes | ~pwm_out;
  assign blank_seconds = in_blank_seconds | ~pwm_out;

endmodule
