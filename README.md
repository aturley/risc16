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
