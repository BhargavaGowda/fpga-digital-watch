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

module user_top_stopwatch_v1 #(
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

  logic rise_start_stop;
  logic rise_lap;

  logic lap_hold;
  logic counter_enable;
  logic counter_rst;
  logic [6:0] minutes;
  logic [5:0] seconds;
  logic [6:0] centiseconds;
  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold),
      .counter_rst(counter_rst)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_cents_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(centiseconds),
      .q(seconds_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_secs_mux (
      .clk(clk),
      .hold(lap_hold),
      .d({1'b0, seconds}),
      .q(minutes_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_mins_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(minutes),
      .q(hours_disp)
  );

  rising_edge_detector u_start (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  rising_edge_detector u_lap (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .enable(counter_enable),
      .rst(counter_rst),
      .centiseconds(centiseconds),
      .seconds(seconds),
      .minutes(minutes)
  );

  assign led = 10'b0;
  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;


endmodule
