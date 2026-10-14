`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst = '0,
    output logic counter_enable = '0,
    output logic lap_hold = '0
);

  always_ff @(posedge clk) begin
    counter_enable <= (rise_start_stop & ~rise_lap) ? ~counter_enable : counter_enable;
  end

  always_ff @(posedge clk) begin
    if (rise_lap & ~rise_start_stop) begin
      lap_hold <= lap_hold ? '0 : counter_enable;
    end
  end

  always_ff @(posedge clk) begin
    counter_rst <= rise_lap & ~rise_start_stop & ~counter_enable & ~lap_hold;
  end


endmodule
