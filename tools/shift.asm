#define LEDR GPO_0
#define LEDG GPO_1

; clear all leds
ldl 0,0
st 0,LEDR
st 0,LEDG

ldl 0,1     ; green led register
ldl 1,0     ; red led register
ldl 4,1     ; shift amount

green_left:

    st 0,TMR_RST        ; reset the timer
delay_0:                ; wait for timer to trigger
    ld 5,TMR_TRIG
    brz 5,delay_0

    st 0,LEDG           ; output R0 to green leds
    sfl 0,0,4           ; shift R0 to left by R4 (R4=1)
    brnz 0,green_left   ; keep shifting until we roll of left side

; green rolled off left side
ldl 1,1                 ; set R1 to turn on right most led
st 0,LEDG               ; output R0 to green leds
st 1,LEDR               ; output R1 to red leds

red_left:

    st 0,TMR_RST        ; reset the timer
delay_1:                ; wait for timer to trigger
    ld 5,TMR_TRIG
    brz 5,delay_1

    st 1,LEDR           ; output R1 to red leds
    sfl 1,1,4           ; shift R1 to left by R4 (R4=1)
    brnz 1,red_left     ; if leds are zero we went off left side

; red rolled off left side
ldl 0,1                 ; set R0 to turn on right most led
st 1,LEDR               ; output R1 to red leds
st 0,LEDG               ; output R0 to green leds

jmp green_left
