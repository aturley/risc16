import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure, TestSuccess

DATA_MEMORY_DEPTH = 256
INSTRUCTION_MEMORY_DEPTH = 256


class CPU(object):
    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.mem = dut.mem
        self.instr = dut.instr
        self.pc = dut.pc
        self.regs = dut.regs
        self.ir = dut.ir
        self.opcode = dut.opcode
        self.ra = dut.ra
        self.rb = dut.rb
        self.rc = dut.rc
        self.imm = dut.imm
        self.signed_imm = dut.ext_signed_imm

    def load_memory_with_value(self, memory_handle, memory_addr, val):
        memory_handle[memory_addr].setimmediatevalue(val)

    def read_memory_value(self, memory_addr):
        return int(self.mem[memory_addr].value)

    def load_file_into_memory(self, fn, memory_handle):
        with open(fn, "r") as f:
            contents = f.read()

        for i, line in enumerate(contents.split("\n")[:-1]):
            v = int(line, 16)
            self.load_memory_with_value(memory_handle, i, v)

    def load_instructions_from_file(self, fn):
        self.load_file_into_memory(fn, self.instr)

    def load_data_from_file(self, fn):
        self.load_file_into_memory(fn, self.mem)

    @cocotb.coroutine
    async def startup(self):
        for i in range(DATA_MEMORY_DEPTH):
            self.mem[i].setimmediatevalue(0)

        for i in range(INSTRUCTION_MEMORY_DEPTH):
            self.instr[i].setimmediatevalue(0)

        cocotb.fork(Clock(self.clk, 2, units="ns").start())
        await RisingEdge(self.clk)
        await RisingEdge(self.clk)
        await RisingEdge(self.clk)

    @cocotb.coroutine
    async def reset(self):
        self.dut.pc.setimmediatevalue(255)
        await RisingEdge(self.clk)


# @cocotb.test()
# async def test_add(dut):


@cocotb.test()
async def loop_test(dut):
    cpu = CPU(dut)
    await cpu.startup()
    await cpu.reset()

    cpu.load_instructions_from_file(
        "../nested-loop/nested-loop.mem"
    )
    cpu.load_data_from_file("../nested-loop/nested-loop.mem")

    old_r5 = -1
    
    # for i in range(140000):
    while(True):
        await RisingEdge(cpu.clk)
        wb = int(cpu.mem[34].value)
        if wb == 1:
            for i in range(0, 16):
                print(f"board : mem[{(i+2):#0{4}x}] == " + (f"{int(cpu.mem[i + 2].value):#0{18}b}").replace('0', '_').replace('1', 'X'))
            print("---")


    print(f"pc == {int(cpu.pc.value)}")
    print(f"wb == {int(cpu.mem[34].value)}")

    for i in range(0, 16):
        print(f"board : mem[{(i+2):#0{4}x}] == {int(cpu.mem[i + 2].value):#0{18}b}")

    print("")

    for i in range(0, 16):
        print(f"buffer : mem[{(i+18):#0{4}x}] == {int(cpu.mem[i + 18].value):#0{18}b}")

    if r5 == 8:
        raise TestSuccess()
    else:
        raise TestFailure()


# @cocotb.test()
# async def program_test(dut):
#    cpu = CPU(dut)
#    await cpu.startup()
#    await cpu.reset()
#
#    cpu.load_instructions_from_file("/Users/kale/recurse/risc16/testprog.mem")
#    for i in range(20):
#        await RisingEdge(cpu.clk)
#
#    expected_val = 1
#    if int(cpu.regs[5].value) == expected_val:
#        raise TestSuccess()
#    else:
#        print(int(cpu.regs[5].value))
#        raise TestFailure()
