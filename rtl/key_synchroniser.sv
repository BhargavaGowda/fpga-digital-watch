`timescale 1ns / 1ps
module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active-low, asynchronous
    output logic [3:0] key_sync = '0  // active-high, synchronised
);

  logic [3:0] buffer = '0;

  always_ff @(posedge clk) begin
    buffer   <= ~key_n;
    key_sync <= buffer;
  end

endmodule
