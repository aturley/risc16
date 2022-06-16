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
start:  movi r7, stack
        addi r7, r7, 2

        add r1, r0, r0
        sw r1, r7, -1
loop1:  movi r2, x_lim
        lw r2, r2, 0
        beq r1, r2, loop1x
        add r0, r0, r0

        add r3, r0, r0
        sw r3, r7, -2
loop2:  movi r2, y_lim
        lw r2, r2, 0
        beq r3, r2, loop2x
        add r0, r0, r0

        # BEGIN WORK
        movi r6, cella
        jalr r6, r6

        beq r6, r0, workx
        movi r4, buffer
        lw r4, r1,

        

workx:  add r0, r0, r0
        
        # END WORK

        lw r3, r7, -2
        addi r3, r3, 1
        sw r3, r7, -2
        beq r0, r0, loop2
        add r0, r0, r0

loop2x: lw r1, r7, -1
        addi r1, r1, 1
        sw r1, r7, -1
        beq r0, r0, loop1
        add r0, r0, r0

        # BEGIN COPY BUFF

        addi r2, r0, 16
copyl:  addi r2, r2, -1
        beq r2, r0, copylx
        add r0, r0, r0
        movi r6, board
        add r6, r6, r2
        lw r4, r6, 16
        sw r4, r6, 0
        beq r0, r0, copyl

copylx: add r0, r0, r0
        
        # END COPY BUFF

loop1x: movi r1, wb
        addi r2, r0, 1
        sw r1, r2, 0
        beq r0, r0, loop1x
        add r0, r0, r0

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
