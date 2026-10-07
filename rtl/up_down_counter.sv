`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  logic [WIDTH-1:0] next_count;

  always_comb begin
    next_count = count;
    if (up) next_count = count == Max ? '0 : count + 1'b1;
    else next_count = count == 0 ? Max : count - 1'b1;
  end

  always_ff @(posedge clk) begin
    if (enable) count <= next_count;
  end
endmodule
