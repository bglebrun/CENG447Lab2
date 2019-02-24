;
; lab_02.asm
;
; Created: 2/16/2019 13:50:57
; Author : Ben & Ben
;
;
; USING:
; PORTB Pins 0-7
;
; DDRB - The Port D Data Direction Register - read/write
; PORTB - The Port D Data Register - read/write
; PINB - The Port D Input Pins Register - read only
;
; PORTB = B10101000; // sets digital pins 7,5,3 HIGH
;
; (from https://www.arduino.cc/en/Reference/PortManipulation)
;
;
.cseg
; reset interrupt vector, should just immediately restart the program
.org 0x0000
	rjmp start

; UART recieve interrupt
.org 0x0024
	rcall UART_RX
	reti

.org 0x0034

; UART initialization
UART_Init:
	push	uart_buf
	push	uart_buf2
	lds		uart_buf, UCSR0B
	;ori		uart_buf, 0x18 ; original line (rx and tx)
	ori		uart_buf, 0x98 ; (enable rx,tx, and rx interrupt)
	sts		UCSR0B, uart_buf ; enables rx tx

	lds		uart_buf, UCSR0C
	ori		uart_buf, 0x06
	sts		UCSR0C, uart_buf ; 8n1 async

	ldi		uart_buf, high(BAUD_PRESCALE)
	ldi		uart_buf2, low(BAUD_PRESCALE)
	sts		UBRR0H, uart_buf
	sts		UBRR0L, uart_buf2
	pop		uart_buf2
	pop		uart_buf
	ret
; UART transmit, messages should be put in the uart_buf register
UART_TX:
	push	uart_buf
	lds		uart_buf, UCSR0A
	sbrs	uart_buf, UDRE0	; Check if there's data to read
	rjmp	UART_TX			; Loop if there is waiting data
	
	rcall	itoa ; convert num to 'alpha'

	sts		UDR0, alpha ; output alphanumeric
	pop		uart_buf
	ret
; UART recieve,reads from out_buf register
; Uses the UART RX Complete interrupt
UART_RX:
	lds		out_buf, UDR0
	mov		alpha, out_buf ; move what we read into the 'alpha' register
	rcall	atoi ; set num from 'alpha'
	ret

flash_leds:
	out		PORTB, num
	rcall	UART_TX
	ret

clear_leds:
	ldi		tmp, 0x00
	out		PORTB, tmp
	ret

; Replace with your application code
.org 0x0100

; UART configuration
.equ F_CPU = 16000000
.equ BAUDRATE = 9600
.equ BAUD_PRESCALE = F_CPU / (BAUDRATE*16)-1
; defines r16 as output buffer
.def out_buf = r16		; uart rx buffer
.def uart_buf = r17		; uart tx buffer
.def uart_buf2 = r18	; overflow buffer
.def num = r24			; value we flash to LEDs
.def alpha = r23		; value we send to uart
.def tmp = r22			; tmp location

.include "wait2.asm"
; Initialization funciton, should be called for every reset interrupt
start:
	clr		r1
	out		SREG, r1			; clear sreg for safety

	ldi		r16, 0xff			; load 0x11111111 to reg 16
	out		DDRB, r16			; set portb to output

	clr		r16					; clear it because it's one of our buffers

	ldi		num, 7
	rcall	itoa

	ldi		r28, LOW(RAMEND)
	ldi		r29, HIGH(RAMEND)
	out		SPL, r28
	out		SPH, r29

	rcall	UART_INIT
	sei
    rjmp	prgmloop
; Main program loop
prgmloop:
	rcall wait_1_second
	rcall wait_1_second
	rcall flash_leds
	rcall wait_1_second
	rcall wait_1_second
	rcall clear_leds
	;rcall incnum ; consider moving inc num to 
			; clear_leds func (to prevent interrupts from messing with value)
	rjmp prgmloop

; itoa function for our bit to ascii code for digits 0 through 10
; in - num in byte
; out - alpha in ASCII code
itoa:
	mov		tmp, num
	subi	tmp, 0 -'0'
	mov		alpha,  tmp
	ret

; atoi function for our ascii to bit representation for digits 0 through 10
; in - alpha in ASCII code
; out - num in byte code
atoi:
	mov		tmp, alpha
	subi	tmp, '0'
	mov		num, tmp
	ret
