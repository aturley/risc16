# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../cpu.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL files
TOPLEVEL = cpu

# Module is the basename of the Python test file
MODULE = cpu_tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
