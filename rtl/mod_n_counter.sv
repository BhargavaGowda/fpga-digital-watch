`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = '0
);
  logic [WIDTH-1:0] next_count;

  always_comb begin
    if (enable) next_count = count == WIDTH'(N - 1) ? 0 : count + 1'b1;
    else next_count = count;

  end

  always_ff @(posedge clk) begin
    count <= rst ? 0 : next_count;
  end

endmodule
