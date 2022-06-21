        beq r0, r0, start
        add r0, r0, r0

board:  .fill 1
        .fill 1
        .fill 0
        .fill 0
        .fill 0
        .fill 0x0200
        .fill 0x0100
        .fill 0x0700
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 0
        .fill 1

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

life:   add r5, r0, r0          # r5 = 0
        add r1, r0, r0          # r1 will hold x for now, which is 0
        sw r1, r7, -1           # store x to sp - 1
loop1:  addi r2, r0, 16         # load x_limit (16) in to r2
        beq r1, r2, loop1x      # if r1 == r2 exit outer loop
        add r0, r0, r0          # nop

        add r3, r0, r0          # r3 will hold y for now, which is 0
        sw r3, r7, -2           # store y to sp - 2
loop2:  addi r2, r0, 16         # load y_limit (16) in to r2
        beq r3, r2, loop2x      # if r3 == r2, break from the inner loop
        add r0, r0, r0          # nop

        # BEGIN WORK

        addi r7, r7, 1          # sp+1
        sw r5, r7, -1           # push r5

        add r2, r3, r0          # r2 <- r3, nbrpp expects x in r2
        movi r6, nbrpp          # load nbrpp into r6
        jalr r6, r6             # jump to r6, on return r6 will contain the returned value
        add r0, r0, r0
        add r4, r0, r6          # store neighbor population in r4

        movi r6, cella          # load cella into r6
        jalr r6, r6             # jump to r6, on return r6 will contain the returned value
        add r0, r0, r0

        add r1, r0, r6          # store cell population in r1
        add r2, r0, r4          # store surrounding population in r2

        movi r6, nxtgn          # load nxtgn into r6
        jalr r6, r6             # jump to r6
        add r0, r0, r0          # nop

        beq r6, r0, dead        # if the next generation at this position is dead, don't set it

        lw r1, r7, -2           # load x
        lw r2, r7, -3           # load y

        movi r4, buffer         # load buffer address into r4
        add r4, r4, r1          # r4 <- buffer + x_offset
        lw r5, r4, 0            # r5 <- *(buffer + x_offset)

        movi r6, mask           # load mask into r6
        add r6, r6, r2          # r6 <- mask + y_offset
        lw r6, r6, 0            # r6 <- *(mask + y_offset)

        add r6, r6, r5          # r6 <- *(buffer + x_offset) + mask
        sw r6, r4, 0            # r6 -> *(buffer + x_offset)

dead:   lw r5, r7, -1           # pop r5
        addi r7, r7, -1         # sp-1      
        
        # END WORK

        lw r3, r7, -2           # load sp - 2 (y) into r3
        addi r3, r3, 1          # increment r3 (y++)
        sw r3, r7, -2           # store r3 into sp - 2 (y)
        beq r0, r0, loop2       # go back to loop2

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
        sw r0, r6, 16           # clear the buffer cell
        beq r0, r0, copyl       # jump back to the beginning of the loop

copylx: add r0, r0, r0

        # END COPY BUFF

        # BEGIN STROBE WB
        
        movi r1, wb             # load address of wb into r1
        addi r2, r0, 1          # r2 <- 1
        sw r2, r1, 0            # mem[r1] <- r2
        sw r0, r1, 0            # mem[r1] <- 0

        # END STROBE WB
        
        movi r6, life
        jalr r6, r6
        add r0, r0, r0          # nop

        # r1 -> x
        # r2 -> y
        # r3! -> tmp
        # r4! -> tmp
        # r5! -> tmp
        # r6! -> retaddr, retval
        # r7 -> sp
cella:  addi r7, r7, 5
        sw r6, r7, -5         # store the contents of r6 (the return address) at sp-3
        sw r1, r7, -4         # push r1
        sw r2, r7, -3         # push r2
        sw r3, r7, -2         # push r3
        sw r4, r7, -1         # push r4

        # Get lower 4 bits of x and y, this makes them wrap around at 16
        addi r3, r0, 0x000F   # r3 <- 0x000F
        nand r1, r1, r3       # r1 <- ~(r1 & r3)
        nand r1, r1, r1       # r1 <- ~r1, get lower 4 bits of x
        nand r2, r2, r3       # r2 <- ~(r2 & r3)
        nand r2, r2, r2       # r2 <- ~r2, get lower 4 bits of r2

        movi r3, board        # load address of board into r3
        add r3, r3, r1        # r3 <- board + x_offset
        lw r3, r3, 0          # r3 <- *(board + x_offset)

        movi r4, mask         # load address of mask into r4
        add r4, r4, r2        # r4 <- mask + y_offset
        lw r4, r4, 0          # r4 <- *(mask + y_offset)

        nand r5, r4, r3       # r5 <- ~(r4 & r3), all cells exept selected cell will be 1, selected cell will be zero if alive
        nand r5, r5, r5       # r5 <- ~r5, invert r5 so that it is 0 unless the selected cell is alive

        beq r5, r4, cellax   # branch to cellax if the isolated cell is equal to the mask (the cell was alive)
        addi r6, r0, 1       # this gets executed even on the branch (r6 == 1 or r6 == 0) BRANCH DELAY BABY!
        addi r6, r6, -1      # decrement r6 if branch was skipped    (r6 == 0 if there was no branch)
        
cellax: lw r5, r7, -5        # put the return address in r5
        lw r1, r7, -4        # pop r1
        lw r2, r7, -3        # pop r2
        lw r3, r7, -2        # pop r3
        lw r4, r7, -1        # pop r4
        
        addi r7, r7, -5      # decrement sp
        jalr r0, r5          # return
        add r0, r0, r0       # nop

        # r1 -> population of cell (1 = alive / 0 = dead)
        # r2 -> surrounding population
        # r5 -> reserved
        # r6 -> retaddr, retval
nxtgn:  addi r7, r7, 2       # sp + 2
        sw r6, r7, -2        # push r6
        sw r4, r7, -1        # push r4

        movi r4, livtab      # move address of dedtab to r4
        add r4, r4, r1       # r4 <- r4 + r1, offset by 1 if the cell is currently alive
        lw r4, r4, 0         # r4 <- *(livtab + alive)

        movi r5, mask        # load the address of mask into r5
        add r5, r5, r2       # increment the index by the value of the surrounding population
        lw r5, r5, 0         # load the correct mask

        nand r4, r4, r5      # r4 <- ~(r4 & r5), begin r4 & r5
        nand r4, r4, r4      # r4 <- ~(r4), finish r4 & r5

        beq r4, r5, nxtgnx   # if r4 == mask then jump to nxtgnx
        addi r6, r0, 1       # this gets executed no matter what happens in the above branch
        addi r6, r6, -1      # r6 <- r6 - 1, so that r6 goes back to 0
        
nxtgnx: lw r5, r7, -2        # pop r5
        lw r4, r7, -1        # pop r4
        addi r7, r7, -2      # sp - 2
        jalr r0, r5          # return
        add r0, r0, r0       # nop

        # nbrpp -- neighbor population
        # given x,y, calculate the population surrounding cells
        # r1 -> x
        # r2 -> y
        # r5 -> reserved
        # r6 -> retaddr, retval
nbrpp:  addi r7, r7, 5       # sp + 5
        sw r6, r7, -5        # push r6
        sw r1, r7, -4        # push r1
        sw r2, r7, -3        # push r2
        sw r3, r7, -2        # push r3
        sw r4, r7, -1        # push r4

        movi r3, noff        # r3 <- noff, r3 points to the beginning of the neighbor offset list
        add r5, r0, r0       # r5 <- 0
nbrppl: lw r1, r7, -4        # r1 <- x
        lw r2, r7, -3        # r2 <- y
        lw r4, r3, 0         # r4 <- current neighbor x offset

        # check to see if we should exit the loop
        addi r4, r4, -9      # r4 <- (current neighbor x offset) - 9
        beq r4, r0, nbrppx   # if r == 0, exit the loop
        addi r4, r4, 9       # r4 <- current neighbor x offset

        # add the x offset to the current x
        add r1, r1, r4       # r1 <- x + x_offset

        lw r4, r3, 1         # r4 <- current neighbor y offset
        add r2, r2, r4       # r2 <- y + y_offset

        add r4, r0, r5       # r4 <- r5
        
        movi r6, cella       # start call cella
        jalr r6, r6          # finish call cella
        add r0, r0, r0

        add r5, r6, r4       # r5 <- running total of population count + result of cella
        
        addi r3, r3, 2       # increment r3 to next neighbor offset pair
        beq r0, r0, nbrppl   # branch to beginning of loop
        add r0, r0, r0       # nop

nbrppx: add r6, r0, r5       # r6 <- population total
        lw r5, r7, -5        # pop r5 (return address)
        lw r1, r7, -4        # pop r1
        lw r2, r7, -3        # pop r2
        lw r3, r7, -2        # pop r3
        lw r4, r7, -1        # pop r4
        addi r7, r7, -5      # sp-5
        jalr r0, r5          # return
        add r0, r0, r0       # nop
        
stack:  .space 16

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

        # These two values are bitmaps where the bit address is equal to the 
        # surrounding population, and the value at that address tells whether
        # or not the cell will be alive in the next generation. If the cell is
        # currently dead then use the first value, if the cell is currently
        # alive then use the second one.
livtab: .fill 0x0008   # 0000 0000 0000 1000
        .fill 0x000C   # 0000 0000 0000 1100

        # neighbor offsets
noff:   .fill -1 # NW
        .fill -1
        .fill -1 # N
        .fill 0
        .fill -1 # NE
        .fill 1
        .fill 0  # W
        .fill -1
        .fill 0  # E
        .fill 1
        .fill 1  # SW
        .fill -1
        .fill 1  # S
        .fill 0
        .fill 1  # SW
        .fill 1
        .fill 9  # END
        .fill 9
