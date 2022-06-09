lw 1,0,count        # load reg1 with 5 (uses symbolic address)
lw 2,1,2            # load reg2 with -1 (uses numeric address)
start: add 1,1,2    # decrement reg1 -- could have been addi 1,1,-1
beq 0,1,1           # goto end of program when reg1==0
beq 0,0,start       # go back to the beginning of the loop
done: halt          # end of program
count: .fill 5
neg1: .fill -1
startAddr: .fill start # will contain the address of start (2)
