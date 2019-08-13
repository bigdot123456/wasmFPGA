SHELL=/bin/bash -o pipefail

SRC   = src
BUILD = build

NAME = wasmachine
DEPS = $(SRC)/genrom.v $(SRC)/$(NAME).v

VENDOR_DEPS = -y vendor/fpu/double_to_float \
							-y vendor/fpu/float_to_double \
							-y vendor/LEB128

IVERILOG = iverilog -g2005-sv -I $(SRC) -y $(SRC) $(VENDOR_DEPS) $(parameters)
GTKWAVE  = gtkwave
VVP      = vvp -N

RED=\033[0;31m
GREEN=\033[0;32m
NC=\033[0m

ECHO = echo -e


all: test $(NAME).bin


clean:
	rm -rf *.bin *.txt *.blif $(BUILD) *~

update-dependencies:
	git submodule update --remote


.PHONY: all clean update-dependencies

ifndef VERBOSE
.SILENT:
endif


#
# General test objectives
#
test           : test/stack test/SuperStack test/genrom test/cpu
test/genrom    : $(BUILD)/genrom_tb.vcd
test/stack     : $(BUILD)/stack_tb.vcd
test/SuperStack: $(BUILD)/SuperStack_tb.vcd
test/%         : $(BUILD)/%_tb.vcd

$(BUILD)/%_tb.vcd: $(BUILD)/%_tb
	( \
		cd $(BUILD) && $(VVP) ../$< | \
		(grep -v -e "opened for output" \
						 -e "Not enough words in the file for the requested range" \
		|| true) \
	) \
	&& $(ECHO) "$(GREEN)ok$(NC)" \
	|| ($(ECHO) "$(RED)FAIL$(NC)" && exit 1)

$(BUILD)/%_tb: test/%_tb.v $(SRC)/%.v test/assert.vh
	$(ECHO) -n $<"... "
	mkdir -p $(@D)
	$(IVERILOG) -I test $< -o $@

view/%: test/%
	$(GTKWAVE) $(BUILD)/$(@F)_tb.vcd test/$(@F)_tb.gtkw


# cpu
test/cpu: test/cpu/control_flow_operators test/cpu/call_operators \
					test/cpu/parametric_operators test/cpu/variable_access \
					test/cpu/constants test/cpu/comparison_operators \
					test/cpu/numeric_operators test/cpu/conversions \
					test/cpu/reinterpretations

test/cpu/control_flow_operators: test/cpu/block test/cpu/loop test/cpu/if \
																 test/cpu/else test/cpu/br test/cpu/br_if \
																 test/cpu/br_table test/cpu/return
test/cpu/block: $(BUILD)/cpu/block_tb.vcd
test/cpu/loop: $(BUILD)/cpu/loop_tb.vcd
test/cpu/if: test/cpu/if1 test/cpu/if2
test/cpu/if1: $(BUILD)/cpu/if1_tb.vcd
test/cpu/if2: $(BUILD)/cpu/if2_tb.vcd
test/cpu/else: test/cpu/else1 test/cpu/else2
test/cpu/else1: $(BUILD)/cpu/else1_tb.vcd
test/cpu/else2: $(BUILD)/cpu/else2_tb.vcd
test/cpu/br: $(BUILD)/cpu/br_tb.vcd
test/cpu/br_if: $(BUILD)/cpu/br_if_tb.vcd
test/cpu/br_table: test/cpu/br_table1 test/cpu/br_table2 test/cpu/br_table3
test/cpu/br_table1: $(BUILD)/cpu/br_table1_tb.vcd
test/cpu/br_table2: $(BUILD)/cpu/br_table2_tb.vcd
test/cpu/br_table3: $(BUILD)/cpu/br_table3_tb.vcd
test/cpu/return: $(BUILD)/cpu/return_tb.vcd

test/cpu/call_operators: test/cpu/call
test/cpu/call : test/cpu/call1 test/cpu/call2
test/cpu/call1: $(BUILD)/cpu/call1_tb.vcd
test/cpu/call2: $(BUILD)/cpu/call2_tb.vcd

test/cpu/parametric_operators: test/cpu/drop test/cpu/select
test/cpu/drop   : $(BUILD)/cpu/drop_tb.vcd
test/cpu/select : test/cpu/select1 test/cpu/select2 test/cpu/select3
test/cpu/select1: $(BUILD)/cpu/select1_tb.vcd
test/cpu/select2: $(BUILD)/cpu/select2_tb.vcd
test/cpu/select3: $(BUILD)/cpu/select3_tb.vcd

test/cpu/variable_access: test/cpu/get_local1 test/cpu/get_local2 \
													test/cpu/set_local test/cpu/tee_local
test/cpu/get_local1: $(BUILD)/cpu/get_local1_tb.vcd
test/cpu/get_local2: $(BUILD)/cpu/get_local2_tb.vcd
test/cpu/set_local: $(BUILD)/cpu/set_local_tb.vcd
test/cpu/tee_local: $(BUILD)/cpu/tee_local_tb.vcd

test/cpu/constants: test/cpu/f32.const test/cpu/f64.const test/cpu/i32.const \
	                  test/cpu/i64.const
test/cpu/f32.const: $(BUILD)/cpu/f32.const_tb.vcd
test/cpu/f64.const: $(BUILD)/cpu/f64.const_tb.vcd
test/cpu/i32.const: $(BUILD)/cpu/i32.const_tb.vcd
test/cpu/i64.const: $(BUILD)/cpu/i64.const_tb.vcd

test/cpu/comparison_operators: test/cpu/i32.eqz test/cpu/i32.eq \
															 test/cpu/i32.ne test/cpu/i64.eqz \
															 test/cpu/i64.eq test/cpu/i64.ne
test/cpu/i32.eqz : test/cpu/i32.eqz1 test/cpu/i32.eqz2
test/cpu/i32.eqz1: $(BUILD)/cpu/i32.eqz1_tb.vcd
test/cpu/i32.eqz2: $(BUILD)/cpu/i32.eqz2_tb.vcd
test/cpu/i32.eq : test/cpu/i32.eq1 test/cpu/i32.eq2
test/cpu/i32.eq1: $(BUILD)/cpu/i32.eq1_tb.vcd
test/cpu/i32.eq2: $(BUILD)/cpu/i32.eq2_tb.vcd
test/cpu/i32.ne : test/cpu/i32.ne1 test/cpu/i32.ne2
test/cpu/i32.ne1: $(BUILD)/cpu/i32.ne1_tb.vcd
test/cpu/i32.ne2: $(BUILD)/cpu/i32.ne2_tb.vcd
test/cpu/i64.eqz : test/cpu/i64.eqz1 test/cpu/i64.eqz2
test/cpu/i64.eqz1: $(BUILD)/cpu/i64.eqz1_tb.vcd
test/cpu/i64.eqz2: $(BUILD)/cpu/i64.eqz2_tb.vcd
test/cpu/i64.eq : test/cpu/i64.eq1 test/cpu/i64.eq2
test/cpu/i64.eq1: $(BUILD)/cpu/i64.eq1_tb.vcd
test/cpu/i64.eq2: $(BUILD)/cpu/i64.eq2_tb.vcd
test/cpu/i64.ne : test/cpu/i64.ne1 test/cpu/i64.ne2
test/cpu/i64.ne1: $(BUILD)/cpu/i64.ne1_tb.vcd
test/cpu/i64.ne2: $(BUILD)/cpu/i64.ne2_tb.vcd

test/cpu/numeric_operators: test/cpu/i32.add test/cpu/i32.sub test/cpu/i64.add \
														test/cpu/i64.sub
test/cpu/i32.add: $(BUILD)/cpu/i32.add_tb.vcd
test/cpu/i32.sub: $(BUILD)/cpu/i32.sub_tb.vcd
test/cpu/i64.add: $(BUILD)/cpu/i64.add_tb.vcd
test/cpu/i64.sub: $(BUILD)/cpu/i64.sub_tb.vcd

test/cpu/conversions: test/cpu/f32.demote-f64
test/cpu/f32.demote-f64: $(BUILD)/cpu/f32.demote-f64_tb.vcd

test/cpu/conversions: test/cpu/i32.wrap-i64
test/cpu/i32.wrap-i64: $(BUILD)/cpu/i32.wrap-i64_tb.vcd

test/cpu/reinterpretations: test/cpu/i32.reinterpret-f32 \
														test/cpu/i64.reinterpret-f64 \
														test/cpu/f32.reinterpret-i32 \
														test/cpu/f64.reinterpret-i64
test/cpu/i32.reinterpret-f32: $(BUILD)/cpu/i32.reinterpret-f32_tb.vcd
test/cpu/i64.reinterpret-f64: $(BUILD)/cpu/i64.reinterpret-f64_tb.vcd
test/cpu/f32.reinterpret-i32: $(BUILD)/cpu/f32.reinterpret-i32_tb.vcd
test/cpu/f64.reinterpret-i64: $(BUILD)/cpu/f64.reinterpret-i64_tb.vcd


$(BUILD)/cpu/%_tb.vcd: $(BUILD)/cpu/%_tb $(BUILD)/cpu/%.hex
	( \
		cd $(BUILD)/cpu && $(VVP) ../../$< | \
		(grep -v -e "opened for output" \
						 -e "Not enough words in the file for the requested range" \
		|| true) \
	) \
	&& $(ECHO) "$(GREEN)ok$(NC)" \
	|| ($(ECHO) "$(RED)FAIL$(NC)" && exit 1)

$(BUILD)/cpu/%.hex:
	mkdir -p $(@D)
	cp test/cpu/$(@F) $(BUILD)/cpu

$(BUILD)/cpu/%_tb: test/cpu/%_tb.v $(SRC)/cpu.v test/assert.vh
	$(ECHO) -n $<"... "
	mkdir -p $(@D)
	$(IVERILOG) -I test $< -o $@

view/cpu/%: test/cpu/%
	$(GTKWAVE) $(BUILD)/cpu/$(@F)_tb.vcd test/cpu/cpu_tb.gtkw


# genrom
$(BUILD)/genrom_tb.vcd: $(BUILD)/genrom_tb
	cp test/genrom.hex $(BUILD)
	( \
		cd $(BUILD) && $(VVP) ../$< | \
		(grep -v -e "opened for output" \
						 -e "Not enough words in the file for the requested range" \
		|| true) \
	) \
	&& $(ECHO) "$(GREEN)ok$(NC)" \
	|| ($(ECHO) "$(RED)FAIL$(NC)" && exit 1)


#------------------------------
#-- Sintesis completa
#------------------------------
$(NAME).bin: resources/$(NAME).pcf $(DEPS) test/prog.list

	#-- Sintesis
	yosys -p "synth_ice40 -blif $(NAME).blif" $(DEPS)

	#-- Place & route
	arachne-pnr -d 1k -p resources/$(NAME).pcf $(NAME).blif -o $(NAME).txt

	#-- Generar binario final, listo para descargar en fgpa
	icepack $(NAME).txt $(NAME).bin
