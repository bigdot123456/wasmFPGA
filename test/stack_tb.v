`include "assert.vh"

`include "stack.vh"


module Stack_tb();

  parameter WIDTH = 8;
  parameter DEPTH = 1;  // frames (exponential)

  localparam MAX_STACK = (1 << DEPTH+1) - 1;

  reg              clk = 0;
  reg              reset;
  reg  [      1:0] op;
  reg  [WIDTH-1:0] data;
  wire [WIDTH-1:0] tos;
  wire [1:0]       status;
  wire [1:0]       error;

  stack #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
  )
  dut(
    .clk(clk),
    .reset(reset),
    .op(op),
    .data(data),
    .tos(tos),
    .status(status),
    .error(error)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("stack_tb.vcd");
    $dumpvars(0, Stack_tb);

    // `status` is `empty` by default
    `assert(status, `EMPTY);

    // Underflow
    op   <= `POP;
    data <= 0;
    #2
    `assert(error, `UNDERFLOW);

    // Push
    op   <= `PUSH;
    data <= 0;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h00);

    op   <= `PUSH;
    data <= 1;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h01);

    op   <= `PUSH;
    data <= 2;
    #2
    `assert(status, `FULL);
    `assert(tos   , 8'h02);

    // Top of Stack
    op <= `NONE;
    #2
    `assert(status, `FULL);
    `assert(tos   , 8'h02);

    // Overflow
    op   <= `PUSH;
    data <= 3;
    #2
    `assert(error, `OVERFLOW);
    `assert(tos  , 8'h02);

    // Pop
    op   <= `POP;
    data <= 0;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h01);

    op   <= `POP;
    data <= 0;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h00);

    op   <= `POP;
    data <= 0;
    #2
    `assert(status, `EMPTY);

    // Replace
    op   <= `REPLACE;
    data <= 4;
    #2
    `assert(error, `UNDERFLOW);

    op   <= `PUSH;
    data <= 5;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h05);

    op   <= `REPLACE;
    data <= 6;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h06);

    op <= `NONE;
    #2
    `assert(status, `NONE);
    `assert(tos   , 8'h06);

    // Reset
    reset <= 1;
    #2
    reset <= 0;
    `assert(status, `EMPTY);

    $finish;
  end

endmodule
