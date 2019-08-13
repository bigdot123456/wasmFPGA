// Control flow operators
`define op_unreachable 8'h00
`define op_nop         8'h01
`define op_block       8'h02
`define op_loop        8'h03
`define op_if          8'h04
`define op_else        8'h05
`define op_end         8'h0b
`define op_br          8'h0c
`define op_br_if       8'h0d
`define op_br_table    8'h0e
`define op_return      8'h0f

// Call operators
`define op_call          8'h10

// Parametric operators
`define op_drop   8'h1a
`define op_select 8'h1b

// Variable access
`define op_get_local  8'h20
`define op_set_local  8'h21
`define op_tee_local  8'h22

// Memory-related operators

// Constants
`define op_i32_const 8'h41
`define op_i64_const 8'h42
`define op_f32_const 8'h43
`define op_f64_const 8'h44

// Comparison operators
`define op_i32_eqz  8'h45
`define op_i32_eq   8'h46
`define op_i32_ne   8'h47
`define op_i32_lt_s 8'h48
`define op_i32_lt_u 8'h49
`define op_i32_gt_s 8'h4a
`define op_i32_gt_u 8'h4b
`define op_i32_le_s 8'h4c
`define op_i32_le_u 8'h4d
`define op_i32_ge_s 8'h4e
`define op_i32_ge_u 8'h4f
`define op_i64_eqz  8'h50
`define op_i64_eq   8'h51
`define op_i64_ne   8'h52
`define op_i64_lt_s 8'h53
`define op_i64_lt_u 8'h54
`define op_i64_gt_s 8'h55
`define op_i64_gt_u 8'h56
`define op_i64_le_s 8'h57
`define op_i64_le_u 8'h58
`define op_i64_ge_s 8'h59
`define op_i64_ge_u 8'h5a

// Numeric operators
`define op_i32_clz    8'h67
`define op_i32_ctz    8'h68
`define op_i32_popcnt 8'h69
`define op_i32_add    8'h6a
`define op_i32_sub    8'h6b
`define op_i32_mul    8'h6c
`define op_i32_div_s  8'h6d
`define op_i32_div_u  8'h6e
`define op_i32_rem_s  8'h6f
`define op_i32_rem_u  8'h70
`define op_i32_and    8'h71
`define op_i32_or     8'h72
`define op_i32_xor    8'h73
`define op_i32_shl    8'h74
`define op_i32_shr_s  8'h75
`define op_i32_shr_u  8'h76
`define op_i32_rotl   8'h77
`define op_i32_rotr   8'h78
`define op_i64_clz    8'h79
`define op_i64_ctz    8'h7a
`define op_i64_popcnt 8'h7b
`define op_i64_add    8'h7c
`define op_i64_sub    8'h7d
`define op_i64_mul    8'h7e
`define op_i64_div_s  8'h7f
`define op_i64_div_u  8'h80
`define op_i64_rem_s  8'h81
`define op_i64_rem_u  8'h82
`define op_i64_and    8'h83
`define op_i64_or     8'h84
`define op_i64_xor    8'h85
`define op_i64_shl    8'h86
`define op_i64_shr_s  8'h87
`define op_i64_shr_u  8'h88
`define op_i64_rotl   8'h89
`define op_i64_rotr   8'h8a

// Conversions
`define op_i32_wrap_i64      8'ha7
`define op_i64_extend_s_i32  8'hac
`define op_i64_extend_u_i32  8'had
`define op_f32_demote_f64    8'hb6
`define op_f64_promote_f32   8'hbb

// Reinterpretations
`define op_i32_reinterpret_f32 8'hbc
`define op_i64_reinterpret_f64 8'hbd
`define op_f32_reinterpret_i32 8'hbe
`define op_f64_reinterpret_i64 8'hbf
