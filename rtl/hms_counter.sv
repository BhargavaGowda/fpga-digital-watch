`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  // number of seconds

    // Output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
  localparam logic [W_SECONDS-1:0] LastSecond = W_SECONDS'(N_SECONDS - 1'b1);
  localparam logic [W_MINUTES-1:0] LastMinute = W_MINUTES'(N_MINUTES - 1'b1);

  logic second_rollover;
  logic minute_rollover;
  logic [W_SECONDS-1:0] previous_second = '0;
  logic [W_MINUTES-1:0] previous_minute = '0;

  up_down_counter #(
      .MAX  (int'(LastSecond)),
      .WIDTH(W_SECONDS)
  ) u_second_counter (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

  up_down_counter #(
      .MAX  (int'(LastMinute)),
      .WIDTH(W_MINUTES)
  ) u_minutes_counter (
      .clk(second_rollover),
      .enable(enable),
      .up(1'b1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (N_HOURS - 1'b1),
      .WIDTH(W_HOURS)
  ) u_hours_counter (
      .clk(minute_rollover),
      .enable(enable),
      .up(1'b1),
      .count(hours)
  );

  always_ff @(posedge clk) begin
    previous_second <= seconds;
  end

  always_ff @(posedge clk) begin
    previous_minute <= minutes;
  end

  always_comb begin
    second_rollover = previous_second == LastSecond ? '1 : '0;
    minute_rollover = previous_minute == LastMinute && minutes == 0 ? '1 : '0;
  end


endmodule
