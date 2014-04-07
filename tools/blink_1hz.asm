#define LEDR GPO_0
#define LEDG GPO_1

; 1Hz blink = 0.5s delays
; 50Mhz clock = 20ns
; 0.5s / 20ns = 2.5E7 = 01 7D 78 40
stl 0x01,TMR_3
stl 0x7D,TMR_2
stl 0x78,TMR_1
stl 0x40,TMR_0

ldl r0,0xFF         ; led value will be stored in R0

loop:

    inv r0,r0       ; flip state of R0 (R0 = ~R0)
    st r0,LEDG      ; update the leds

    stl 0,TMR_RST   ; reset the timer
delay:              ; wait for timer to trigger
    ld r1,TMR_TRIG
    brz r1,delay

    jmp loop
