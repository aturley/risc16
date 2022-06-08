module cpu(
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
   wire signed [6:0]    signed_imm;

   assign opcode = ir[15:13];
   assign ra = ir[12:10];
   assign rb = ir[9:7];
   assign rc = ir[2:0];
   assign signed_imm = ir[6:0];
   
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

        $readmemh("mem.mem", mem);
        $readmemb("instr_loads_and_adds.mem", instr);
     end // initial begin

   initial
     begin
        $dumpvars(1, cpu);
        for(i = 0; i < 8; i = i + 1)
          begin
             $dumpvars(1, regs[i]);
          end
     end

   always @ (posedge clk)
     begin
        pc <= pc + 1;
     end

   always @ (posedge clk)
     begin
        ir <= instr[pc];
     end

   localparam ADD = 'b000;
   localparam LW  = 'b100;
   
   always @ (posedge clk)
     begin
        case (opcode)
          ADD:
            begin
               if (ra != 0)
                 begin
                    regs[ra] <= regs[rb] + regs[rc];
                 end
            end
          LW:
            begin
               if (ra != 0)
                 begin
                    // memory_address = regs[rb] + signed_imm
                    // regs[ra] = mem[memory_address]
                    regs[ra] <= mem[regs[rb] + signed_imm];
                 end
            end
        endcase
     end
endmodule
