; clear all leds
ldi 0,0
st 0,ledr
st 0,ledg

ldi 0,1     ; green led register
ldi 1,0     ; red led register
ldi 4,1     ; shift amount

green_left:
    st 0,ledg           ; output R0 to green leds
    sfl 0,0,4           ; shift R0 to left by R4 (R4=1)
    brnz 0,green_left   ; keep shifting until we roll of left side

; green rolled off left side
ldi 1,1                 ; set R1 to turn on right most led
st 0,ledg               ; output R0 to green leds
st 1,ledr               ; output R1 to red leds

red_left:
    st 1,ledr           ; output R1 to red leds
    sfl 1,1,4           ; shift R1 to left by R4 (R4=1)
    brnz 1,red_left     ; if leds are zero we went off left side

; red rolled off left side
ldi 0,1                 ; set R0 to turn on right most led
st 1,ledr               ; output R1 to red leds
st 0,ledg               ; output R0 to green leds

jmp green_left
