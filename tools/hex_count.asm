.define HEX_0 GPO_2
.define HEX_1 GPO_3
.define HEX_2 GPO_4
.define HEX_3 GPO_5

ldl r0, 0   ; 1s place
ldl r1, 0   ; 10s place
ldl r2, 0   ; 100s place
ldl r3, 0   ; 1000s place

ldl r4, 10

loop:

    inc r0                  ; increment the 1s place
    eql r5,r0,r4            ; check if it is now == 10
    brz r5,display          ; if nots 10 display current number
    ldl r0,0                ; it was 10 so reset it to 0

    inc r1                  ; increment the 10s place
    eql r5,r1,r4            ; check if it is now == 10
    brz r5,display          ; if not 10 display current number
    ldl r1,0                ; it was 10 so reset it to 0

    inc r2                  ; increment the 100s place
    eql r5,r2,r4            ; check if it is now == 10
    brz r5,display          ; if not 10 display current number
    ldl r2,0                ; it was 10 so reset it to 0

    inc r3                  ; increment the 1000s place
    eql r5,r3,r4            ; check if it is now == 10
    brz r5,display          ; if not 10 display current number
    ldl r3,0                ; it was 10 so reset it to 0

display:                    ; update the HEX displays
    st r0,HEX_0
    st r1,HEX_1
    st r2,HEX_2
    st r3,HEX_3

    stl 0,TMR_RST           ; reset the timer
delay_loop:                 ; wait for timer to trigger
    ld r10,TMR_TRIG
    brz r10,delay_loop

    jmp loop
