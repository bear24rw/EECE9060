ldi 0,0
ldi 1,1

main:
    st 0,LEDG
    st 0,LEDR
    add 0,0,1
    jmp main
