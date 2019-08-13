/*
 * Stack
 *
 * (c) 2017 - Jesús Leganés-Combarro 'piranna' <piranna@gmail.com>
 *
 * Based on https://github.com/whitequark/bfcpu2/blob/master/verilog/Stack.v
 */

`include "stack.vh"


`default_nettype none

module stack
#(
  parameter WIDTH = 8,  // bits
  parameter DEPTH = 3   // frames (exponential)
)
(
  input clk,
  input reset,

  input  [      1:0] op,    // none / push / pop / replace
  input  [WIDTH-1:0] data,  // Data to be inserted on the stack
  output [WIDTH-1:0] tos,   // What's currently on the Top of Stack

  output reg [1:0] status = `EMPTY,  // none / empty / full / underflow
  output reg [1:0] error  = `NONE    // none / underflow / overflow
);

  localparam MAX_STACK = (1 << DEPTH+1) - 1;

  reg [WIDTH-1:0] stack [0:MAX_STACK-1];
  reg [  DEPTH:0] index = 0;

  assign tos = stack[index-1];

  // Adjust status when index has changed
  always @* begin
    if(index == MAX_STACK)
      status <= `FULL;
    else if(index == 0)
      status <= `EMPTY;
    else
      status <= `NONE;
  end

  always @(posedge clk) begin
    error <= `NONE;

    if (reset)
      index <= 0;

    else
      case(op)
        `PUSH:
        begin
          // Stack is full
          if (index == MAX_STACK)
            error <= `OVERFLOW;

          // Push data to ToS
          else begin
            stack[index] <= data;

            index <= index + 1;
          end
        end

        `POP:
        begin
          if (index-data <= 0)
            error <= `UNDERFLOW;

          else
            index <= index - (1+data);
        end

        `REPLACE:
        begin
          if (index == 0)
            error <= `UNDERFLOW;

          else
            stack[index-1] <= data;
        end
      endcase
  end

endmodule
