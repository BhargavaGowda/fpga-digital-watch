`timescale 1ns / 1ps
module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed = '0
);

  always_ff @(posedge clk) begin
    armed <= (arm | armed) & ~disarm;

  end

endmodule
