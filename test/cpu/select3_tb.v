`include "assert.vh"

`include "cpu.vh"


module cpu_tb();

  reg clk = 0;


  //
  // ROM
  //

  localparam MEM_ADDR  = 4;
  localparam MEM_EXTRA = 4;

  reg  [      MEM_ADDR  :0] mem_addr;
  reg  [     MEM_EXTRA-1:0] mem_extra;
  reg  [      MEM_ADDR  :0] rom_lower_bound = 0;
  reg  [      MEM_ADDR  :0] rom_upper_bound = ~0;
  wire [2**MEM_EXTRA*8-1:0] mem_data;
  wire                      mem_error;

  genrom #(
    .ROMFILE("select3.hex"),
    .AW(MEM_ADDR),
    .DW(8),
    .EXTRA(MEM_EXTRA)
  )
  ROM (
    .clk(clk),
    .addr(mem_addr),
    .extra(mem_extra),
    .lower_bound(rom_lower_bound),
    .upper_bound(rom_upper_bound),
    .data(mem_data),
    .error(mem_error)
  );


  //
  // CPU
  //

  reg         reset = 0;
  wire [63:0] result;
  wire        result_empty;
  wire [ 3:0] trap;

  cpu #(
    .MEM_DEPTH(MEM_ADDR)
  )
  dut
  (
    .clk(clk),
    .reset(reset),
    .result(result),
    .result_empty(result_empty),
    .trap(trap),
    .mem_addr(mem_addr),
    .mem_extra(mem_extra),
    .mem_data(mem_data),
    .mem_error(mem_error)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("select3_tb.vcd");
    $dumpvars(0, cpu_tb);

    #24
    `assert(trap, `TYPES_MISMATCH);

    $finish;
  end

endmodule
