        beq r0, r0, start
        add r0, r0, r0

board:  .fill 1
        .fill 2
        .fill 3
        .fill 4
        .fill 5
        .fill 6
        .fill 7
        .fill 8
        .fill 9
        .fill 10
        .fill 11
        .fill 12
        .fill 13
        .fill 14
        .fill 15
        .fill 16

buffer: .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0

wb:     .fill 0

        # r7 -> sp
        # sp - 1 -> x
        # sp - 2 -> y
start:  movi r7, stack          # set r7 to beginning of stack
        addi r7, r7, 2          # sp + 2, because we have 2 local variables (x and y)

        add r1, r0, r0          # r1 will hold x for now, which is 0
        sw r1, r7, -1           # store x to sp - 1
loop1:  movi r2, x_lim          # start loading the x limit into r2
        lw r2, r2, 0            # finish loading the x limit into r2
        beq r1, r2, loop1x      # if r1 == r2 exit outer loop
        add r0, r0, r0          # nop

        add r3, r0, r0          # r3 will hold y for now, which is 0
        sw r3, r7, -2           # store y to sp - 2
loop2:  movi r2, y_lim          # start loading the y limit into r2
        lw r2, r2, 0            # finish loading the y limit into r2
        beq r3, r2, loop2x      # if r3 == r2, break from the inner loop
        add r0, r0, r0          # nop

        # BEGIN WORK

        add r5, r1, r3          # r5 <- r1 + r3 (r5 = x + y) THIS IS A THING TO TEST
        
        # END WORK

        lw r3, r7, -2           # load sp - 2 (y) into r3
        addi r3, r3, 1          # increment r3 (y++)
        sw r3, r7, -2           # store r3 into sp - 2 (y)
        beq r0, r0, loop2       # go back to loop2
        add r0, r0, r0          # nop

loop2x: lw r1, r7, -1           # load sp - 1 (x) into r1
        addi r1, r1, 1          # increment r1 (x++)
        sw r1, r7, -1           # store r1 into sp - 1 (x)
        beq r0, r0, loop1       # go back to loop1
        add r0, r0, r0          # nop

loop1x: add r0, r0, r0

        # BEGIN COPY BUFF

        addi r2, r0, 16         # put 16 in r2
copyl:  addi r2, r2, -1         # subtract 1 from r2
        addi r3, r2, 1          # r3 <- r2 + 1
        beq r3, r0, copylx      # if r3 == 0 then exit loop
        add r0, r0, r0          # nop
        movi r6, board          # load board address into r6
        add r6, r6, r2          # r6 <- r6 + r2 (board + offset)
        lw r4, r6, 16           # r4 <- (r6 + 16), this is the contents of the buffer that corresponds to the board position in r6
        
        sw r4, r6, 0            # mem[r6] <- r4, store the buffered value into the corresponding board position
        beq r0, r0, copyl       # jump back to the beginning of the loop

copylx: add r0, r0, r0

        # END COPY BUFF

        # BEGIN SET WB = 1
        
        movi r1, wb             # load address of wb into r1
        addi r2, r0, 1          # r2 <- 1
        sw r2, r1, 0            # mem[r1] <- r2

        # END SET WB = 1
        
        beq r0, r0, loop1x      # go back to loop1x
        add r0, r0, r0          # nop

        # r1 -> x
        # r2 -> y
        # r3! -> tmp
        # r4! -> tmp
        # r5! -> tmp
        # r6! -> retaddr, retval
        # r7 -> sp
cella:  sw r6, r7, 0
        addi r7, r7, 1
        
        movi r3, mask8
        lw r3, r3, 0
        nand r1, r1, r3
        nand r2, r2, r3

        movi r3, board
        add r3, r3, r1
        lw r3, r3, 0

        movi r4, mask
        add r4, r4, r2
        lw r4, r4, 0

        nand r5, r3, r4
        nand r5, r5, r5

        beq r5, r4, cellax
        addi r6, r0, 1       # this gets executed even on the branch (r6 = 1)
        addi r6, r6, -1      # decrement r6 if branch was skipped    (r6 = 0)
        
cellax: lw r5, r7, -1
        addi r7, r7, -1
        jalr r5, r0
        add r0, r0, r0

x_lim:  .fill 0x03
y_lim:  .fill 0x03

stack:  .space 20

mask:   .fill 0x0001
        .fill 0x0002
        .fill 0x0004
        .fill 0x0008
        .fill 0x0010
        .fill 0x0020
        .fill 0x0040
        .fill 0x0080
        .fill 0x0100
        .fill 0x0200
        .fill 0x0400
        .fill 0x0800
        .fill 0x1000
        .fill 0x2000
        .fill 0x4000
        .fill 0x8000

mask8:  .fill 0x0007
