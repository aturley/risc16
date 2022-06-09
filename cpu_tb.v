module cpu_tb();
   reg clk = 0;

   cpu our_cpu(.clk(clk));

   always #2 
     begin
        clk <= ~clk;
        //$display("clock tick %5d", $time);
    end

   always @ (posedge clk) begin
        $display("ir = %02x %02x", our_cpu.ir[15:8], our_cpu.ir[7:0]);
        $display("r1 = %02x %02x", our_cpu.regs[1][15:8], our_cpu.regs[1][7:0]);
        $display("r2 = %02x %02x", our_cpu.regs[2][15:8], our_cpu.regs[2][7:0]);
        $display("r3 = %02x %02x", our_cpu.regs[3][15:8], our_cpu.regs[3][7:0]);
        $display("r4 = %02x %02x", our_cpu.regs[4][15:8], our_cpu.regs[4][7:0]);
        $display("instructions = %02x %02x", our_cpu.instr[0][15:8], our_cpu.instr[0][7:0]);
        $display("mem[0]= %02x %02x", our_cpu.mem[0][15:8], our_cpu.mem[0][7:0]);
   end

   initial
     begin
        #40
          $finish;
     end
endmodule
