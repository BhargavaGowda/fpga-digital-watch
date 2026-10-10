`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic last_bit = '0;

  always_ff @(posedge clk) begin
    last_bit <= sig_in;

  end

  always_comb begin
    rise = last_bit == '0 && sig_in == '1 ? '1 : '0;
  end

endmodule
