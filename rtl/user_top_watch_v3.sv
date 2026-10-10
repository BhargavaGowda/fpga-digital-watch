// ------------------------------------------------------------------
// basic time display
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_watch_v3 #(
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

  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_counter #(
      .N(60),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  assign minutes_tick = seconds_tick && seconds == 59 && !(mode_enable == 3'b001);
  assign hours_tick = minutes_tick && minutes == 59 && !(mode_enable == 3'b010);

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
      .button(button[3]),
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

  assign seconds_inc = inc;
  assign seconds_dec = dec;
  assign minutes_inc = inc;
  assign minutes_dec = dec;
  assign hours_inc = inc;
  assign hours_dec = dec;

  assign seconds_edit = mode_enable == 3'b001;
  assign minutes_edit = mode_enable == 3'b010;
  assign hours_edit = mode_enable == 3'b100;


endmodule
