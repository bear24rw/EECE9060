#define LEDR GPO_0
#define LEDG GPO_1

; 1Hz blink = 0.5s delays
; 50Mhz clock = 20ns
; 0.5s / 20ns = 2.5E7 = 01 7D 78 40
stl 0x01,TMR_3
stl 0x7D,TMR_2
stl 0x78,TMR_1
stl 0x40,TMR_0

; led value will be stored in R0
ldl 0,0xFF

loop:

    ; flip state of R0 (R0 = ~R0)
    inv 0,0

    ; update the leds
    st 0,LEDG

    ; reset the timer
    st 0,TMR_RST

delay:
    ; wait for timer to trigger
    ld 1,TMR_TRIG
    brz 1,delay

    jmp loop
