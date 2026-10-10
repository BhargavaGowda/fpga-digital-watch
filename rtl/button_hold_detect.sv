`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CounterWidth = $clog2(HOLD_CYCLES) + 1;
  logic count_enable;
  logic count_reset;
  logic [CounterWidth-1:0] count;

  mod_n_counter #(
      .WIDTH(CounterWidth),
      .N(HOLD_CYCLES + 1)
  ) held_counter (
      .clk(clk),
      .enable(count_enable),
      .rst(count_reset),
      .count(count)
  );

  always_comb begin
    count_enable = count == CounterWidth'(HOLD_CYCLES) ? '0 : '1;
    count_reset = button ? '0 : '1;
    held = ~count_enable;
  end



endmodule
