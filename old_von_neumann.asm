.include "tn461def.inc"
;Written for attiny261A @ 8Mhz. This code is awful and unoptimized from like 15 years ago. Seriously, don't use it. Use the new version. It's way better.
;To run at 20Mhz, lengthen the oversampling avoidance pauses WAIT0 and WAIT1
;R20 is iteration number for the entropy accumulator function
;R21 is the entropy accumulator register
;R22 is the entropy output register
;R16 is a general purpose register
;R17 and R18 are timer storage registers

RESET:

;Timer prescale to clock speed... I think it is better at full 8 Mhz speed, gives slightly more bandwidth since measured times are less likely to be equal with increased resolution.

ldi r16, (0<<CS02 | 0<<CS01) | (1<<CS00)
out TCCR0B, r16

;Ensure normal 8-bit mode timer operation. Overflows are OK and actually help with bias, though it should be impossible to measure anyway.

ldi r16, (0<<ICEN0 | 0<<TCW0) | (0<<WGM00)
out TCCR0A, r16

;Set up ports. PortB, Pin 6 is input, pullup resistor enabled. The rest of A&B are used as potential outputs.

ldi r16,0b10111111
out DDRB,r16
ldi r16,0b01000000
out PORTB, r16
ldi r16,0b11111111
out DDRA,r16
clr r20

; Set iteration number to 1

ldi r20, 0b00000001

START:
clr r16

; Wait at least 10 usec (OR IS IT 1usec???), to ensure this pulse won't be oversampled
; This loop may be redundant, but it is important to sample the same way each of these 2 times.

WAIT0:
inc r16
cpi r16, 0x29
brsh SAMPLE0
rjmp WAIT0
SAMPLE0:
clr r16

;CHECK TO MAKE SURE NO INPUT; remember inputs are inverted (if input, start over to avoid oversampling)

sbis PINB,6
rjmp START

;Clear timer

out TCNT0L, r16

;Sample until input detected.

LOOP0:
sbic PINB,6
rjmp LOOP0

;Read timer

in r17,TCNT0L

;Make sure timer did not overflow. If it did, null output. I think this is useless and removed it.
;in r16, TIFR
;sbrc r16,1
;rjmp START
; Wait at least 10 usec (OR IS IT 1usec???), to ensure this pulse won't be oversampled

clr r16
WAIT1:
inc r16
cpi r16, 0x29
brsh SAMPLE1
rjmp WAIT1

SAMPLE1:
clr r16

;CHECK TO MAKE SURE NO INPUT (if input, start over to avoid oversampling)
sbis PINB,6
rjmp START

;Clear timer

out TCNT0L, r16

;Sample until input detected.

LOOP1:
sbic PINB,6
rjmp LOOP1

;Read timer

in r18, TCNT0L

;Make sure timer did not overflow. If it did, null output. I think this is useless and removed it.
;in r16, TIFR
;sbrc r16,1
;rjmp START

clr r16

;Determine whether to output a 1 or 0 (if equal, null output)

cp r17, r18
breq START
cp r17, r18
brsh OUTPUT0
rjmp OUTPUT1

OUTPUT0:

;Since the register is filled with zeroes normally, not much needs to be done here.

cpi r20, 0b10000000
brsh PAROUT

;Rotate the 1 bit to the left

lsl r20
rjmp START

;Put a 0 in ith bit of register 21
;increment i (r20)
;check if i=8. If so, goto PAROUT
;Goto START

OUTPUT1:
add r21,r20
cpi r20,0b1000000
brsh PAROUT

;Rotate the 1 bit to the left

lsl r20
rjmp START
PAROUT:

;reset R20 to 1 to reset iteration number

ldi r20, 0b00000001

;output a random 8-bit number

mov r22,r21
out PORTA,r22
clr r21

;Toggle the "new number ready" pin on status lines of parport
;When a computer is reading the device, it records the new number if current pin status is different than last pin status. The machine can be doing other things, as sampling this way does not rely on precise timing... no need for a dedicated computer to do this!
sbic PINB,1
rjmp TOGGLE1
ldi r16, 0b00000010
out PORTB, r16
rjmp START

TOGGLE1:
clr r16
out PORTB, r16
rjmp START
