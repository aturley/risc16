
addi 2,0,3 			// 0 put 3 into register 2
addi 3,0,incr_r5  	// 1 put the address of `incr_r5` into register 3 
jalr 1,3    		// 3 jump to incr_r5, store pc+1 in register 1
add 0,0,0     		// 4 branch delay slot nop
addi 4,0,63    		// 5 
done:          halt          # end of program
add 0,0,0     		// 6 branch delay slot nop

incr_r5:       addi 5,0,1   // put 1 into register 5
               jalr 0,1		// jump to previously stored address
               add 0,0,0    // branch delay slot
