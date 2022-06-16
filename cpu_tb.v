module cpu_tb();
   reg clk = 0;

   cpu our_cpu(.clk(clk));

   always #2 
     begin
        clk <= ~clk;
        //$display("clock tick %5d", $time);
    end

   integer i;
   localparam NUM_REGISTERS = 8;

   localparam ADD = 'b000;
   localparam ADDI = 'b001;
   localparam NAND = 'b010;
   localparam LUI = 'b011;
   localparam LW  = 'b101;
   localparam SW  = 'b100;
   localparam BEQ  = 'b110;
   localparam JALR  = 'b111;

   initial begin
      //$write("time,");
      //$write("ir,");
      //for (i=0; i < NUM_REGISTERS; i = i + 1) begin
      //   $write("r%01d,", i);
      //end
      //$display("");
    end

   always @ (posedge clk) begin
      //$write("%5d,",$time);
      //$write("%d,", our_cpu.ir);
      //for (i=0; i < NUM_REGISTERS; i = i + 1) begin
      //   $write("%d,", our_cpu.regs[i]);
      //end
      //$display("");
      //
      $display("-------------------------");
      $display("TIME: %05d", $time);
      $display("PC: %03d", our_cpu.pc);
      $display("IR: %02x %02x", our_cpu.ir[15:8], our_cpu.ir[7:0]);
      $write("OPCODE: %01x - ", our_cpu.opcode);
      case (our_cpu.opcode)
        ADD: $write("ADD\n");
        ADDI: $write("ADDI\n");
        NAND: $write("NAND\n");
        LUI: $write("LUI\n");
        LW: $write("LW\n");
        SW: $write("SW\n");
        BEQ: $write("BEQ\n");
        JALR: $write("JALR\n");
        endcase
      $display("RegA: %01x", our_cpu.ra);
      $display("RegB: %01x", our_cpu.rb);
      $display("RegC: %01x", our_cpu.rc);
      $display("Imm: %01x", our_cpu.imm);
      $display("Signed Imm: %01x", our_cpu.ext_signed_imm);
      $display("");


      $display("REGISTERS\t\t\tINSTRUCTION MEM\t\t\tDATA MEM");
      for (i=0; i < NUM_REGISTERS; i = i + 1) begin
         $display("\tR%01d: %d\t\t0x%04x: %04x\t\t0x%04x: %04x", i, our_cpu.regs[i], i, our_cpu.instr[i], i, our_cpu.mem[i]);
        end
        //$display("instructions = %02x %02x", our_cpu.instr[0][15:8], our_cpu.instr[0][7:0]);
        //$display("mem[0]= %02x %02x", our_cpu.mem[0][15:8], our_cpu.mem[0][7:0]);
      $display("");
   end

   initial
     begin
        #100
          $finish;
     end
endmodule
