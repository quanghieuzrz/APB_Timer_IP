#########################################################################
# Makefile for Icarus Verilog (iverilog) & GTKWave
# Author: Hieu Bui
# Example run string: make TESTNAME=TC_COUNTER all
#                      make TESTNAME=TC_HALT all_wave
#########################################################################
# Define variables
TESTNAME        ?= TC_DEFAULT
TB_NAME         ?= test_bench

# Tools
COMPILER        = iverilog
SIMULATOR       = vvp
WAVE_VIEWER     = gtkwave

OUT_FILE        = simv.vvp
LOG_FILE        = $(TESTNAME).log
COMPILE_LOG     = compile.log
VCD_DIR         = sim
VCD_FILE        = wave.vcd

#================================
all: build run

all_wave: build run wave

build:
	@mkdir -p $(VCD_DIR)
	$(COMPILER) -g2012 -D$(TESTNAME) -s $(TB_NAME) -f compile.f -o $(OUT_FILE) 2>&1 | tee $(COMPILE_LOG)

run:
	$(SIMULATOR) $(OUT_FILE) | tee $(LOG_FILE)

wave:
	$(WAVE_VIEWER) $(VCD_FILE) &

clean:
	rm -f $(OUT_FILE)
	rm -f *.log
	rm -f $(COMPILE_LOG)
	rm -rf $(VCD_DIR)

help:
	@echo ""
	@echo "*******************************************************"
	@echo "** make TESTNAME=TC_xxx build    : build design with iverilog"
	@echo "** make TESTNAME=TC_xxx run      : run simulation with vvp"
	@echo "** make TESTNAME=TC_xxx all      : build and run simulation"
	@echo "** make TESTNAME=TC_xxx all_wave : build, run, and open gtkwave"
	@echo "** make wave                     : open waveform ($(VCD_FILE))"
	@echo "** make clean                    : clean generated files"
	@echo ""
	@echo "Available TESTNAME values (must match \`ifdef in test_bench.v):"
	@echo "  TC_ALIGNED, TC_COUNTER, TC_COUNTER_CTRL, TC_DEFAULT, TC_INTERRUPT,"
	@echo "  TC_ONE_HOT, TC_FUTURE_ERROR, TC_RESERVED, TC_HALT, TC_APB_PROTOCOL,"
	@echo "  TC_PSLVERR, TC_PSTRB, TC_BYTE_ACCESS, TC_APB_MULTI"
	@echo ""
	@echo "Example:"
	@echo "  make TESTNAME=TC_COUNTER all"
	@echo "  make TESTNAME=TC_HALT all_wave"
	@echo "*******************************************************"