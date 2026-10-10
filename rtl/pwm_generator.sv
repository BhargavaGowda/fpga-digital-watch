`timescale 1ns / 1ps

module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  logic enable = '1;
  localparam int CounterWidth = $clog2(PERIOD_CYCLES) + 1;
  logic [CounterWidth-1:0] count;
  logic [CounterWidth-1:0] compare = CounterWidth'(PERIOD_CYCLES);

  mod_n_counter #(
      .WIDTH(CounterWidth),
      .N(PERIOD_CYCLES)
  ) pwm_counter (
      .rst(rst),
      .enable(enable),
      .clk(clk),
      .count(count)
  );

  always_comb begin
    pwm_out = count < CounterWidth'(DUTY_CYCLES) ? '1 : '0;
  end


endmodule
