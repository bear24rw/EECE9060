ldi 0,0
ldi 1,1
loop:
add 2,0,1
st 2,100    ; load reg 2 into mem addr 100
ldi 2,66    ; kill reg 2
ld 2,100    ; restore it
mov 0,1
mov 1,2
jmp loop
