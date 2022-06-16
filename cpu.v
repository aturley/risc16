module cpu
(
    input clk
);
   reg [15:0]    mem [255:0]; // RAM: 256 elements of 16-bit memory
   reg [15:0]    instr [255:0]; // instructions: 256 elements of 16-bit memory
   reg [7:0]     pc;
   reg [15:0]    regs [7:0];
   reg [15:0]    ir;
   integer       i;

   wire [2:0]    opcode;
   wire [2:0]    ra;
   wire [2:0]    rb;
   wire [2:0]    rc;
   wire [9:0]           imm;
   wire [15:0]   ext_signed_imm;
   /* verilator lint_off UNUSED */
   wire [15:0]   memory_address;

   /* verilator lint_on UNUSED */


   assign opcode = ir[15:13];
   assign ra = ir[12:10];
   assign rb = ir[9:7];
   assign rc = ir[2:0];
   assign imm = ir[9:0];
   assign ext_signed_imm = {{9{ir[6]}}, ir[6:0]};
   assign memory_address = regs[rb] + ext_signed_imm;
   
   initial
     begin
        pc = 0;

        for (i = 0; i < 8; i = i + 1)
          begin
             regs[i] = 0;
          end

        for (i = 0; i < 256; i = i + 1)
          begin
             mem[i] = 0;
          end

        for (i = 0; i < 256; i = i + 1)
          begin
             instr[i] = 0;
          end
        
        ir = 0;

        // $readmemh("mem.mem", mem);
        // $readmemh("instr.mem", instr);

        //$readmemh("mem.mem", mem);
        // $readmemb("instr_loads_and_adds.mem", instr);
        //$readmemh("testprog.mem", instr);
     end // initial begin

   localparam NUM_INSTRS_DISP = 16;

   initial
     begin
        $dumpvars(1, cpu);
        for(i = 0; i < 8; i = i + 1)
          begin
             $dumpvars(1, regs[i]);
          end
        for(i = 0; i < NUM_INSTRS_DISP; i = i + 1)
          begin
             $dumpvars(1, instr[i]);
          end
     end

   always @ (posedge clk)
     begin
        case (opcode)
          BEQ:
            begin
               if (regs[ra] == regs[rb])
                 begin
                    pc <= pc + 1 + ext_signed_imm[7:0];
                 end
               else
                 begin
                    pc <= pc + 1;
                 end
            end
          JALR:
            begin
               pc <= regs[rb][7:0];
            end
          default:
            begin
             pc <= pc + 1;
            end
          endcase
     end

   always @ (posedge clk)
     begin
        ir <= instr[pc];
     end



   localparam ADD = 'b000;
   localparam ADDI = 'b001;
   localparam NAND = 'b010;
   localparam LUI = 'b011;
   // NOTE: the document that describes this CPU lists LW as both b100 and b101, we have opted to use b101
   // this is in accordance with the behavior of the much maligned assembler
   localparam LW  = 'b101;
   localparam SW  = 'b100;
   // NOTE: Our branch instructions implement a branch delay slot
   localparam BEQ  = 'b110;
   localparam JALR  = 'b111;
   
   always @ (posedge clk)
     begin
        // NOTE: according to the document, r0 should always be 0;
        case (opcode)
          ADD:
            begin
               if (ra != 0)
                 begin
                    regs[ra] <= regs[rb] + regs[rc];
                 end
            end
          ADDI:
            begin
               if (ra != 0)
                 begin
                    regs[ra] <= regs[rb] + ext_signed_imm;
                 end
            end
          NAND:
            begin
               if (ra != 0)
                 begin
                    regs[ra] <= ~(regs[rb] & regs[rc]);
                 end
            end
          LUI:
            begin
               if (ra != 0)
                 begin
                    regs[ra] <= {imm, 6'b0};
                 end
            end
          LW:
            begin
               if (ra != 0)
                 begin
                    regs[ra] <= mem[memory_address[7:0]];
                 end
            end
          JALR: begin
             regs[ra] <= {8'h00, pc};
            end
          //BEQ: BEQ Doesn't modify registers
        endcase
     end

   always @ (posedge clk) begin
      if (opcode == SW)
        begin
            mem[memory_address[7:0]] <= regs[ra];
        end
    end
endmodule
