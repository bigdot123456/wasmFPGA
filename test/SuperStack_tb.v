`include "assert.vh"

`include "SuperStack.vh"


module SuperStack_tb();

  parameter WIDTH = 8;
  parameter DEPTH = 1;  // frames (exponential)

  localparam MAX_STACK = (1 << DEPTH+1) - 1;

  reg              clk = 0;
  reg              reset;
  reg  [      2:0] op;
  reg  [WIDTH-1:0] data;
  reg  [DEPTH  :0] offset;
  reg  [DEPTH  :0] underflow_limit=0;
  reg  [DEPTH  :0] upper_limit=0;
  wire [DEPTH  :0] index;
  wire [WIDTH-1:0] out;
  wire [WIDTH-1:0] out1;
  wire [WIDTH-1:0] out2;
  wire [WIDTH-1:0] getter;
  wire [      1:0] status;
  wire [      1:0] error;

  SuperStack #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .ZEROED_SLICES(1)
  )
  dut(
    .clk(clk),
    .reset(reset),
    .op(op),
    .data(data),
    .offset(offset),
    .underflow_limit(underflow_limit),
    .upper_limit(upper_limit),
    .lower_limit(2'b0),
    .dropTos(1'b0),
    .index(index),
    .out(out),
    .out1(out1),
    .out2(out2),
    .getter(getter),
    .status(status),
    .error(error)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("SuperStack_tb.vcd");
    $dumpvars(0, SuperStack_tb);

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
    `assert(out   , 8'h00);

    op   <= `PUSH;
    data <= 1;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h01);
    `assert(out1  , 8'h00);

    op   <= `PUSH;
    data <= 2;
    #2
    `assert(status, `FULL);
    `assert(out   , 8'h02);
    `assert(out1  , 8'h01);
    `assert(out2  , 8'h00);

    // Top of Stack
    op <= `NONE;
    #2
    `assert(status, `FULL);
    `assert(out   , 8'h02);
    `assert(out1  , 8'h01);
    `assert(out2  , 8'h00);

    // Overflow
    op   <= `PUSH;
    data <= 3;
    #2
    `assert(error, `OVERFLOW);
    `assert(out  , 8'h02);
    `assert(out1 , 8'h01);
    `assert(out2 , 8'h00);

    // Pop
    op   <= `POP;
    data <= 0;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h01);
    `assert(out1  , 8'h00);

    op   <= `POP;
    data <= 0;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h00);

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
    `assert(out   , 8'h05);

    op   <= `REPLACE;
    data <= 6;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h06);

    op <= `NONE;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h06);

    // Reset
    reset <= 1;
    #2
    reset <= 0;
    `assert(status, `EMPTY);
    `assert(index , 0);

    //
    // Underflow limit
    //

    // Underflow after change limit
    op              <= `NONE;
    underflow_limit <= 1;
    #2
    `assert(status, `UNDERFLOW);
    // `assert(out   , 8'h06);
    `assert(index , 0);

    // Push data while we are under the underflow limit...
    // and get an empty stack! Magic! :-P
    op   <= `PUSH;
    data <= 8;
    #2
    `assert(status, `EMPTY);
    `assert(out   , 8'h08);
    `assert(index , 1);

    // Reset with underflow limit set
    op   <= `PUSH;
    data <= 9;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h09);
    `assert(out1  , 8'h08);
    `assert(index , 2);

    op <= `INDEX_RESET;
    offset <= 1;
    #2
    `assert(status, `EMPTY);
    `assert(out   , 8'h08);
    `assert(index , 1);

    // Get underflow error when underflow limit is not zero (data is protected)
    op   <= `POP;
    data <= 0;
    #2
    op <= `NONE;
    `assert(error, `UNDERFLOW);
    `assert(out  , 8'h08);
    `assert(index, 1);

    // Reset underflow limit, and now we can access the data
    underflow_limit <= 0;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h08);
    `assert(index , 1);

    // Get empty when index get zero
    op   <= `POP;
    data <= 0;
    #2
    `assert(status, `EMPTY);
    `assert(index , 0);

    // Underflow reset push
    op <= `INDEX_RESET_AND_PUSH;
    data            <= 10;
    underflow_limit <= 2;
    offset          <= 0;
    #2
    `assert(status, `UNDERFLOW);
    `assert(out   , 8'h0a);
    `assert(index , 1);

    op <= `INDEX_RESET_AND_PUSH;
    data            <= 11;
    underflow_limit <= 0;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h0b);
    `assert(index , 1);

    // Underfow set
    op <= `UNDERFLOW_SET;
    data            <= 12;
    underflow_limit <= 1;
    offset          <= 0;
    #2
    `assert(error, `BAD_OFFSET);
    `assert(out  , 8'h0b);
    `assert(index, 1);

    upper_limit <= 1;
    #2
    `assert(status, `EMPTY);
    `assert(out   , 8'h0c);
    `assert(index , 1);

    op <= `NONE;
    #2
    `assert(status, `EMPTY);
    `assert(index , 1);

    op   <= `PUSH;
    data <= 13;
    #2
    `assert(status, `NONE);
    `assert(out   , 8'h0d);
    `assert(index , 2);

    // Underfow get
    offset <= 0;
    op <= `UNDERFLOW_GET;
    #2
    `assert(status, `NONE);
    `assert(getter, 8'h0c);
    `assert(index , 2);

    offset <= 1;
    op <= `UNDERFLOW_GET;
    #2
    `assert(error, `BAD_OFFSET);
    `assert(index, 2);

    // Reset index over current one and fill with zeroes
    op <= `INDEX_RESET;
    offset <= 3;
    #2
    `assert(status, `FULL);
    `assert(out   , 8'h00);
    `assert(out1  , 8'h0d);
    `assert(out2  , 8'h0c);
    `assert(index , 3);

    $finish;
  end

endmodule
