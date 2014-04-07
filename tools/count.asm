ldl 0,0
main:
    st 0,LEDG
    st 0,LEDR
    inc 0

    ; reset the timer
    st 0,TMR_RST

delay:
    ; wait for timer to trigger
    ld 1,TMR_TRIG
    brz 1,delay

    jmp main
