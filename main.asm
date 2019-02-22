;
; lab_02.asm
;
; Created: 2/16/2019 13:50:57
; Author : Ben L
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

.org 0x0000
	rjmp start

; UART recieve interrupt
.org 0x0024
	rjmp UART_RX
	rcall atoi
	reti

; UART buffer send interrupt
.org 0x0028
	rjmp UART_TX
	rcall itoa
	reti

UART_Init:
	push	uart_buf
	push	uart_buf2
	lds		uart_buf, UCSR0B
	ori		uart_buf, 0x18
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

UART_TX:
	push	uart_buf
	lds		uart_buf, UCSR0A
	sbrs	uart_buf, UDRE0	; Check if there's data to read
	rjmp	UART_TX			; Loop if no

	sts		UDR0, out_buf
	pop		uart_buf
	ret

UART_RX:
	push	out_buf
	lds		out_buf, UCSR0A
	sbrs	out_buf, RXC0	; Check if there's data to write
	rjmp	UART_RX			; Loop if no

	lds		r16, UDR0
	pop		r17
	ret

flash_leds:
	out		PORTB, out_buf
	pop		out_buf
	ret

clear_leds:
	ldi		out_buf, 0x00
	out		PORTB, out_buf
	ret

; Replace with your application code
.org 0x0059

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

start:
  clr		r1
	out		SREG, r1			; clear sreg for safety

	ldi		r16, 0xff			; load 0x11111111 to reg 16
	out		DDRB, r16			; set portb to output

	clr		r16					; clear it because it's one of our buffers

	ldi		num, 0x00
	rcall	itoa

	ldi		r28, LOW(RAMEND)
	ldi		r29, HIGH(RAMEND)
	out		SPL, r28
	out		SPH, r29

	rcall	UART_INIT
	sei
    rjmp	prgmloop

prgmloop:
	rcall wait_1_second
	rcall flash_leds
	rcall wait_1_second
	rcall clear_leds
	inc num
	rjmp prgmloop

itoa:
	mov		tmp, num
	subi	tmp, '0'
	mov		alpha,  tmp
	ret

atoi:
	mov		tmp, alpha
	subi	tmp, 0 - '0'
	mov		num, tmp
	ret
