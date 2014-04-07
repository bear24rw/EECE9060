.define LEDR GPO_0
.define LEDG GPO_1

; clear all leds
stl 0,LEDR
stl 0,LEDG

ldl r0,1     ; green led register
ldl r1,0     ; red led register
ldl r4,1     ; shift amount

green_left:

    stl 0,TMR_RST       ; reset the timer
delay_0:                ; wait for timer to trigger
    ld r5,TMR_TRIG
    brz r5,delay_0

    st r0,LEDG          ; output R0 to green leds
    sfl r0,r0,r4        ; shift R0 to left by R4 (R4=1)
    brnz r0,green_left  ; keep shifting until we roll of left side

; green rolled off left side
ldl r1,1                ; set R1 to turn on right most led
st r0,LEDG              ; output R0 to green leds
st r1,LEDR              ; output R1 to red leds

red_left:

    stl 0,TMR_RST       ; reset the timer
delay_1:                ; wait for timer to trigger
    ld r5,TMR_TRIG
    brz r5,delay_1

    st r1,LEDR          ; output R1 to red leds
    sfl r1,r1,r4        ; shift R1 to left by R4 (R4=1)
    brnz r1,red_left    ; if leds are zero we went off left side

; red rolled off left side
ldl r0,1                ; set R0 to turn on right most led
st r1,LEDR              ; output R1 to red leds
st r0,LEDG              ; output R0 to green leds

jmp green_left
