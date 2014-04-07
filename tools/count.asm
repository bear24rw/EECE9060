.define LEDR GPO_0
.define LEDG GPO_1

ldl r0,0

main:
    st r0,LEDG
    st r0,LEDR
    inc r0

    ; reset the timer
    stl 0,TMR_RST

delay:
    ; wait for timer to trigger
    ld r1,TMR_TRIG
    brz r1,delay

    jmp main
