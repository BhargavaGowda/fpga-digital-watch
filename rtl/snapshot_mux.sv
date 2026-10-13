`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] last_d = '0;

  always_ff @(posedge clk) begin
    last_d <= hold ? last_d : d;
  end

  assign q = hold ? last_d : d;

endmodule
