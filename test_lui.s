#lui 1, 234
#lui 2, 169
#nand 3,1,2     // instruction address
addi 3,0,42   // 0
lw   4,3,-42  // 1
beq  0,0,-2   //2
add 0,0,0     //3
done: halt          # end of program

