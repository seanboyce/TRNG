.include "tn261Adef.inc"
.CSEG
.ORG 0
rjmp RESET ; Reset Handler -- used for handling reset vector
rjmp event ; IRQ0 Handler -- used to detect falling edges for avalance events
rjmp RESET ; PCINT0 Handler -- not used
rjmp RESET ; Timer0 Capture Handler -- not used
rjmp RESET ; Timer0 Overflow Handler -- not used
rjmp RESET ; Timer0 Compare A Handler -- not used
rjmp RESET ; Timer0 Compare B Handler -- not used
rjmp RESET ; USI_OVF Handler -- not used
rjmp RESET ; EEPROM READY Handler -- not used
rjmp RESET ; Analog Comparator Handler -- not used
rjmp RESET ; ADC Conversion Complete Handler -- not used
rjmp RESET ; Watchdog Interrupt Handler -- not used
rjmp RESET ; INT1 -- not used
rjmp RESET ; TIMER0_COMPA -- not used
rjmp RESET ; TIMER0_COMPB -- not used
rjmp RESET ; TIMER0_CAPT -- not used
rjmp RESET ; TIMER1_COMPD -- not used
rjmp RESET ; FAULT_PROTECTION -- not used

RESET:
;BEGIN SETUP SECTION
CLR R16 ; cleanup
LDI r16, (1<<PRADC | 1<<PRTIM1 | 1<<PRUSI | 0<<PRTIM0); disable unused features to save power. We will use timer0.
OUT PRR, r16

ldi r16, (0<<CS02 | 0<<CS01) | (1<<CS00) ; set up timer, no prescaler
out TCCR0B, r16

ldi r16, (0<<ICEN0 | 0<<TCW0) | (0<<WGM00);Ensure normal 8-bit mode timer operation. Overflows are OK.
out TCCR0A, r16

;Set up ports. PortB, Pin 6 is input, pullup resistors disabled. The rest of A&B are used as potential outputs.
ldi r16,0b10111111 ; Set pin 6 as input, others as output
out DDRB,r16
ldi r16,0b00000000 ; make sure pullups are disabled, saves power. Also what's the point of reducing input noise when we're measuring noise?
out PORTB, r16
ldi r16,0b11111111 ; Port A as output
out DDRA,r16

LDI r16, (1<<ISC01 | 0<<ISC00 | 0<<SM0 | 0<<SM1 | 1<<SE); Interrupt on falling edge -- these are the avalanche events, we measure time between them. Set sleep mode IDLE and enable sleep.
;We could use deeper sleep, some state retention, and pin level interrupt instead of falling edge. This would save a little more power (irrelevant), at the cost of more complex code. We're not going to do that. 
OUT MCUCR, r16
LDI r16, (1<<INT0) ; actually enable INT0 (pin 9).
OUT GIMSK, r16
CLR R16 ; cleanup
CLR R21
; END SETUP SECTION


START:
; Set iteration number to 1
ldi r20, 0b00000001

CLR R21 ; clear out any stored entropy

;BEGIN SAMPLE 1 BIT
LOOP:
;WAIT for a first event to happen
SEI
SLEEP
;Now we start timing t1, the time between the first and second events.
out TCNT0L, r16 ; Clear timer
SEI ; enable global interrupt
SLEEP
MOV r17, r18 ; r17 is for the first bit
;Now we start timing t2, the time between the second and third events
out TCNT0L, r16 ; Clear timer
SEI ; enable global interrupt
SLEEP
NOP ; not really needed. Just for CPU cycle symmetry

cp r17, r18
breq LOOP ; if both timers equal, cancel this bit
cp r17, r18
brsh OUTPUT0 ; t1>t2, output 0
rjmp OUTPUT1 ; t1<t2, output 1

event:
IN r18,TCNT0L ; keep our interrupt routine tight
RET ;return but do not enable interrupts yet, we'll manage interrupts manually

OUTPUT0:
NOP ; Not needed. Just for symmetry.
cpi r20,0b10000000
brsh PAROUT
lsl r20 ; rotate iteration counter left -- just moves to the next bit.
RJMP LOOP

OUTPUT1:
add r21,r20
cpi r20,0b10000000
brsh PAROUT
lsl r20 ; rotate iteration counter left -- just moves to the next bit.
RJMP LOOP

PAROUT:
out PORTA,r21
out TCNT0L, r16 ; Clear timer
sbi PINB,1 ;toggle pin up
wait:
IN r18,TCNT0L ; just wait ~30usec. Not worth using sleep modes for this.
CPI r18, 0x50 ; wait 10usec
BRLT wait
sbi PINB,1 ;toggle pin down The reason we do this instead of just toggle once, is that the Pi Pico has no pin change interrupt. So on rising edge, it's always safe to read a value out of PORTA.
RJMP START
