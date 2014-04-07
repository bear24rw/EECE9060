ldl 0,0
ldl 1,1

loop:
    add 2,0,1
    st 2,ledg
    mov 0,1
    mov 1,2

    st 0,TMR_RST        ; reset the timer

delay_0:                ; wait for timer to trigger
    ld 5,TMR_TRIG
    brz 5,delay_0

    jmp loop
