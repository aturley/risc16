# RISC16

## Overview

This is a Verilog implemenation of [a 16-bit RISC](https://user.eng.umd.edu/~blj/RiSC/RiSC-isa.pdf).

## Status

The LW and ADD instructions have been implemented.

## Building and Running

Build the CPU and testbench:

```sh
iverilog -o cpu.vvp cpu.v cpu_tb.v
```

Run it in the simulator:

```sh
vvp cpu.vvp
```
## Building and running the assembler

```sh
clang -std=c11 -Wall -Werror -o assembler assembler.c
```

Run assembler to generate ascii text file with hex bytecode. 
The output file should be compatible with $readmemh so that we can load it into instruction memory.

``` sh
assembler test_assembly.s test.hex
```

