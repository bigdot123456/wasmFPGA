`include "assert.vh"

`include "cpu.vh"


module cpu_tb();

  reg clk = 0;


  //
  // ROM
  //

  localparam MEM_ADDR    = 6;
  localparam MEM_EXTRA   = 4;
  localparam STACK_DEPTH = 7;

  reg  [      MEM_ADDR  :0] mem_addr;
  reg  [     MEM_EXTRA-1:0] mem_extra;
  reg  [      MEM_ADDR  :0] rom_lower_bound = 0;
  reg  [      MEM_ADDR  :0] rom_upper_bound = ~0;
  wire [2**MEM_EXTRA*8-1:0] mem_data;
  wire                      mem_error;

  genrom #(
    .ROMFILE("tee_local.hex"),
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

  parameter HAS_FPU = 1;
  parameter USE_64B = 1;

  reg                  reset = 1;
  reg  [   MEM_ADDR:0] pc    = 17;
  reg  [STACK_DEPTH:0] index = 1;
  wire [         63:0] result;
  wire [          1:0] result_type;
  wire                 result_empty;
  wire [          3:0] trap;

  cpu #(
    .HAS_FPU(HAS_FPU),
    .USE_64B(USE_64B),
    .MEM_DEPTH(MEM_ADDR),
    .STACK_DEPTH(STACK_DEPTH)
  )
  dut
  (
    .clk(clk),
    .reset(reset),
    .pc(pc),
    .index(index),
    .result(result),
    .result_type(result_type),
    .result_empty(result_empty),
    .trap(trap),
    .mem_addr(mem_addr),
    .mem_extra(mem_extra),
    .mem_data(mem_data),
    .mem_error(mem_error)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("tee_local_tb.vcd");
    $dumpvars(0, cpu_tb);

    #1
    reset <= 0;

    if(USE_64B) begin
      #39
      `assert(result, 2);
      `assert(result_type, `i64);
      `assert(result_empty, 0);
    end
    else begin
      #12
      `assert(trap, `NO_64B);
    end

    $finish;
  end

endmodule
