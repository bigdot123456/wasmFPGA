`include "assert.vh"


module genrom_tb();

  parameter AW    = 4;
  parameter DW    = 8;
  parameter EXTRA = 4;

  reg                    clk = 0;
  logic[           AW:0] addr;
  logic[      EXTRA-1:0] extra;
  logic[           AW:0] lower_bound=0;
  logic[           AW:0] upper_bound=9;
  wire [DW*2**EXTRA-1:0] data;
  wire                   error;

  genrom #(
    .AW(AW),
    .DW(DW),
    .ROMFILE("genrom.hex")
  )
  dut(
    .clk(clk),
    .addr(addr),
    .extra(extra),
    .lower_bound(lower_bound),
    .upper_bound(upper_bound),
    .data(data),
    .error(error)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("genrom_tb.vcd");
    $dumpvars(0, genrom_tb);

    addr  <= 0;
    extra <= 0;
    #2
    `assert(error, 0);
    `assert(data , 128'h81);

    addr  <= 1;
    extra <= 1;
    #2
    `assert(error, 0);
    `assert(data , 128'h0082);

    addr  <= 3;
    extra <= 3;
    #2
    `assert(error, 0);
    `assert(data , 128'h00840088);

    addr  <= 0;
    extra <= 4;
    #2
    `assert(error, 0);
    `assert(data , 128'h8100820084);

    addr  <= 0;
    extra <= 7;
    #2
    `assert(error, 0);
    `assert(data , 128'h8100820084008800);

    addr  <= 0;
    extra <= 15;
    #2
    `assert(error, 0);
    `assert(data , 128'h81008200840088008140xxxxxxxxxxxx);

    addr  <= 9;
    extra <= 0;
    #2
    `assert(error, 0);

    addr  <= 10;
    extra <= 0;
    #2
    `assert(error, 1);

    $finish;
  end

endmodule
