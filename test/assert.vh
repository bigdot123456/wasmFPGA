/**
 * Based on code from http://stackoverflow.com/a/31302223/586382
 */
`define assert(signal, value) \
  if (signal !== value) begin \
    `ifdef __LINE__ \
      $display("ASSERTION FAILED in %m:%d: signal != value", `__LINE__); \
    `else \
      $display("ASSERTION FAILED in %m: signal != value"); \
    `endif \
    $stop; \
  end
