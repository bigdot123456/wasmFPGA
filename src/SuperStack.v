/*
 * SuperStack
 *
 * (c) 2017 - Jesús Leganés-Combarro 'piranna' <piranna@gmail.com>
 *
 * Based on https://github.com/whitequark/bfcpu2/blob/master/verilog/Stack.v
 */

`include "SuperStack.vh"


`default_nettype none

module SuperStack
#(
  parameter WIDTH = 8,  // bits
  parameter DEPTH = 3,  // frames (exponential)
  parameter ZEROED_SLICES = 0
)
(
  input clk,
  input reset,

  input      [      2:0] op,              // none / push / pop / replace /
                                          // index_reset / index_push /
                                          // underflow_get / underflow_set
  input      [WIDTH-1:0] data,            // Data to be inserted on the stack
  input      [DEPTH  :0] offset,          // position of getter/setter/new index
  input      [DEPTH  :0] underflow_limit, // Depth of underflow error
  input      [DEPTH  :0] upper_limit,     // Underflow get/set upper limit
  input      [DEPTH  :0] lower_limit,     // Underflow get/set lower limit
  input                  dropTos,
  output reg [DEPTH  :0] index = 0,       // Current top of stack position
  output     [WIDTH-1:0] out,             // top of stack
  output     [WIDTH-1:0] out1,
  output     [WIDTH-1:0] out2,

  output reg [WIDTH-1:0] getter,  // Output of getter

  output reg [1:0] status = `EMPTY,  // none / empty / full / underflow
  output reg [1:0] error  = `NONE    // none / underflow / overflow
);

  localparam MAX_STACK = (1 << DEPTH+1) - 1;

  reg [WIDTH-1:0] stack [0:MAX_STACK-1];

  assign out  = stack[index-1];
  assign out1 = stack[index-2];
  assign out2 = stack[index-3];

  // Adjust status when index or underflow limit or stack content has¡ve changed
  always @* begin
    if(index == MAX_STACK)
      status <= `FULL;
    else if(index == underflow_limit)
      status <= `EMPTY;
    else if(index < underflow_limit)
      status <= `UNDERFLOW;
    else
      status <= `NONE;
  end

  /**
   * Fill the stack slices with zeroes if new index is greater than current one
   */
  task zeroedIndex;
    reg [$clog2(DEPTH+1):0] i;
    reg [       DEPTH   :0] j;
    reg [       DEPTH   :0] o = 0;
    reg [       DEPTH   :0] slice;

    // By disabling the filling of zeroes we improve performance more than twice
    // (25-60 MHz) almost up to the regular stack (70 MHz). Alternatives would
    // be to do the zeroed in parallel by preserving someway the base address
    // for each group, or using a bitmap of the setted variables on each call
    // slice, or do the zeroed in several cycles by using a requests queue.
    if(ZEROED_SLICES && index < offset) begin
      slice = offset - index;

      for(i=0; i < DEPTH+1; i = i + 1)
        if(slice[i])
          for(j=0; j < 2**i; j = j + 1) begin
            stack[index+o] = 0;
            o = o + 1;
          end
    end
  endtask

  always @(posedge clk) begin
    error <= `NONE;

    if(reset)
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
          if (index-data <= underflow_limit)
            error <= `UNDERFLOW;

          else
            index <= index - (1+data);
        end

        `REPLACE:
        begin
          if (index <= underflow_limit)
            error <= `UNDERFLOW;

          else
            stack[index-1] <= data;
        end

        `INDEX_RESET:
        begin
          zeroedIndex();

          index <= offset;
        end

        `INDEX_RESET_AND_PUSH:
        begin
          // New index is equal to MAX_STACK, raise error
          if (offset == MAX_STACK)
            error <= `OVERFLOW;

          else begin
            zeroedIndex();

            stack[offset] <= data;

            index <= offset+1;
          end
        end

        `UNDERFLOW_GET:
        begin
          if (upper_limit - lower_limit <= offset)
            error <= `BAD_OFFSET;

          else
            getter <= stack[lower_limit + offset];
        end

        `UNDERFLOW_SET:
        begin
          if (upper_limit - lower_limit <= offset)
            error <= `BAD_OFFSET;

          else if(dropTos && index == underflow_limit)
            error <= `UNDERFLOW;

          else begin
            stack[lower_limit + offset] <= data;

            if(dropTos) index <= index - 1;
          end
        end
      endcase
  end

endmodule
