
addi 2,0,3 // 0
addi 3,0,incr_r5  // 1
jalr 1,3    // 3
add 0,0,0     //4
addi 4,0,63    //4
done:          halt          # end of program

incr_r5:       addi 5,0,1
               jalr 0,1
               add 0,0,0     //8
