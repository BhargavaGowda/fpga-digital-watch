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

module user_top_timer_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
`ifdef FORMAL
    output logic probe_running,

    output logic [2:0] probe_mode_enable,
`endif
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
  logic running = '0;

  always_ff @(posedge clk) begin
    if (dec) running <= ~running;
    if ((seconds == '0 && minutes == '0 && hours == '0) || mode_enable != '0) running <= '0;
  end

  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick & running),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .clr(seconds == '0 && minutes == '0 && hours == '0),
      .borrow_out(minutes_tick)
  );

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .clr(minutes == '0 && hours == '0),
      .borrow_out(hours_tick)
  );

  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .clr(hours == '0)
  );

  // Accurate time keeping V4

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (running),
      .tick(seconds_tick)
  );

  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign led = 10'b0;


  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)  // Fill in, based on CYCLES_PER_SECOND
  ) u_mode_selector (
      .clk(clk),
      .button(button[3] & ~running),
      .mode_enable(mode_enable)
  );

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) * 0.2)
  ) u_pwm (
      .clk(clk),
      .rst('0),
      .pwm_out(pwm_out)
  );

  always_comb begin

    case (mode_enable)
      3'b001: begin
        blank_seconds = pwm_out;
        blank_minutes = 0;
        blank_hours   = 0;
      end
      3'b010: begin
        blank_seconds = 0;
        blank_minutes = pwm_out;
        blank_hours   = 0;
      end
      3'b100: begin
        blank_seconds = 0;
        blank_minutes = 0;
        blank_hours   = pwm_out;
      end
      default: begin
        blank_seconds = 0;
        blank_minutes = 0;
        blank_hours   = 0;
      end


    endcase
  end
  // --------------
  // Settable Watch
  // --------------

  logic inc;
  logic dec;

  rising_edge_detector u_inc (
      .clk(clk),
      .sig_in(button[1]),
      .rise(inc)

  );

  rising_edge_detector u_dec (
      .clk(clk),
      .sig_in(button[0]),
      .rise(dec)

  );

  logic inc_held;
  logic dec_held;
  logic inc_repeat;
  logic dec_repeat;

  button_hold_detect #(
      .HOLD_CYCLES(CYCLES_PER_SECOND / 2 + 1)
  ) u_inc_hold_detect (
      .clk(clk),
      .button(button[1]),
      .held(inc_held)
  );

  button_hold_detect #(
      .HOLD_CYCLES(CYCLES_PER_SECOND / 2 + 1)
  ) u_dec_hold_detect (
      .clk(clk),
      .button(button[0]),
      .held(dec_held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 10)
  ) inc_pulse_train (
      .clk (clk),
      .run (inc_held),
      .tick(inc_repeat)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 10)
  ) dec_pulse_train (
      .clk (clk),
      .run (dec_held),
      .tick(dec_repeat)
  );


  assign seconds_inc = inc | inc_repeat;
  assign seconds_dec = dec | dec_repeat;
  assign minutes_inc = inc | inc_repeat;
  assign minutes_dec = dec | dec_repeat;
  assign hours_inc = inc | inc_repeat;
  assign hours_dec = dec | dec_repeat;

  assign seconds_edit = mode_enable == 3'b001;
  assign minutes_edit = mode_enable == 3'b010;
  assign hours_edit = mode_enable == 3'b100;

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
