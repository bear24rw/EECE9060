.define LEDR GPO_0  ; red leds are on GPO 0
.define LEDG GPO_1  ; green leds are on GPO 1

ldl r0,0            ; initialize register 0 to 0

main:
    st r0,LEDG      ; output register 0 to green leds
    st r0,LEDR      ; output register 0 to red leds
    inc r0          ; increment register 0

    stl 0,TMR_RST   ; reset the timer by writing to the TMR_RST address

delay:
    ld r1,TMR_TRIG  ; get the status of the timer trigger
    brz r1,delay    ; if its still zero keep delaying

    jmp main        ; go back and do it all again
