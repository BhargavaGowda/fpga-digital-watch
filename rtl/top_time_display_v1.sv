`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);
  localparam int WidthHours = 5;
  localparam int WidthMinutes = 6;
  localparam int WidthSeconds = 6;

  logic enable;
  logic clk1;
  logic clk25;
  logic clk1k;
  logic hms_enable;
  logic [WidthHours-1:0] hours;
  logic [WidthMinutes-1:0] minutes;
  logic [WidthSeconds-1:0] seconds;
  logic [3:0] h_digit_10;
  logic [3:0] h_digit_1;
  logic [3:0] m_digit_10;
  logic [3:0] m_digit_1;
  logic [3:0] s_digit_10;
  logic [3:0] s_digit_1;
  logic blank;
  assign blank  = '0;
  assign enable = '1;


  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) rate1 (
      .clk ((CLOCK_50)),
      .run (enable),
      .tick(clk1)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) rate25 (
      .clk ((CLOCK_50)),
      .run (enable),
      .tick(clk25)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) rate1k (
      .clk ((CLOCK_50)),
      .run (enable),
      .tick(clk1k)
  );



  always_comb begin
    case (SW)
      2'b00:   hms_enable = clk1;
      2'b01:   hms_enable = clk25;
      2'b10:   hms_enable = clk1k;
      2'b11:   hms_enable = CLOCK_50;
      default: hms_enable = clk1;
    endcase
  end



  hms_counter u_hms_counter (
      .clk(CLOCK_50),
      .enable(hms_enable),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  binary_to_bcd u_bcd_hours (
      .bin ({2'b0, hours}),
      .ones(h_digit_1),
      .tens(h_digit_10)
  );
  binary_to_bcd u_bcd_minutes (
      .bin ({1'b0, minutes}),
      .ones(m_digit_1),
      .tens(m_digit_10)
  );
  binary_to_bcd u_bcd_seconds (
      .bin ({1'b0, seconds}),
      .ones(s_digit_1),
      .tens(s_digit_10)
  );

  seven_segment ss_h10 (
      .digit(h_digit_10),
      .blank(blank),
      .segments(HEX5)
  );
  seven_segment ss_h1 (
      .digit(h_digit_1),
      .blank(blank),
      .segments(HEX4)
  );
  seven_segment ss_m10 (
      .digit(m_digit_10),
      .blank(blank),
      .segments(HEX3)
  );
  seven_segment ss_m1 (
      .digit(m_digit_1),
      .blank(blank),
      .segments(HEX2)
  );
  seven_segment ss_s10 (
      .digit(s_digit_10),
      .blank(blank),
      .segments(HEX1)
  );
  seven_segment ss_s1 (
      .digit(s_digit_1),
      .blank(blank),
      .segments(HEX0)
  );


endmodule
