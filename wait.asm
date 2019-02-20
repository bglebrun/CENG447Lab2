;
;  wait.asm
;  
;  Poor implementation of a 1 second wait using
;  function calls.
;
;  simulation testing appears to be partially correct,
;  wait_1_second takes about 1.04 seconds.
;
;  Created: 2/19/2019 12:41:31 PM
;   Author: Benjamin Garcia
; 

.def i = r16
.def j = r17
.def k = r18
.def l = r19

rjmp start

; void wait_10_microseconds();
; waits 160 cycles
wait_10_microseconds:
	push i
	ldi i, 0x25 ; load 37
	loop_i_wait_10_microseconds:
		dec i
		breq end_i_wait_10_microseconds
		rjmp loop_i_wait_10_microseconds
	end_i_wait_10_microseconds: ; 37 * 4 - 1 = 147 cycles
	nop
	nop
	nop
	clz ; clear zero flag
	pop i
	ret

; void wait_1_millisecond();
; waits 16,000 cycles
wait_1_millisecond:
	push i
	push j
	ldi i, 0x5f ; load 95
	loop_i_wait_1_millisecond:
		rcall wait_10_microseconds
		dec i
		breq end_i_wait_1_millisecond
		rjmp loop_i_wait_1_millisecond
	end_i_wait_1_millisecond: ; 95*167 - 1 = 15864
	clz ; clear zero flag
	ldi j, 0x1e ; load 30
	loop_j_wait_1_millisecond:
		dec j
		breq end_j_wait_1_millisecond
		rjmp loop_j_wait_1_millisecond
	end_j_wait_1_millisecond: ; 30 * 4 - 1 = 119
	clz ; clear zero flag
	nop
	pop j
	pop i
	ret

; void wait_100_milliseconds();
; waits 1,600,000 cycles
wait_100_milliseconds:
	push i
	push j
	push k
	ldi i, 0x63 ; load 99
	loop_i_wait_100_milliseconds:
		rcall wait_1_millisecond
		dec i
		breq end_i_wait_100_milliseconds
		rjmp loop_i_wait_100_milliseconds
	end_i_wait_100_milliseconds: ; 99 * 16007 - 1 = 1584692
	clz ; clear zero flag
	ldi j, 0x5b ; load 91
	loop_j_wait_100_milliseconds:
		rcall wait_10_microseconds
		dec j
		breq end_j_wait_100_milliseconds
		rjmp loop_j_wait_100_milliseconds
	end_j_wait_100_milliseconds: ; 91 * 167 - 1 = 15196
	clz ; clear zero flag
	ldi k, 0x16 ; load 22
	loop_k_wait_100_milliseconds:
		dec k
		breq end_k_wait_100_milliseconds
		rjmp loop_k_wait_100_milliseconds
	end_k_wait_100_milliseconds: ; 22 * 4 - 1 = 87
	nop
	nop
	nop
	clz ; clear zero flag
	pop k
	pop j
	pop i
	ret

; void wait_1_second();
; waits 16,000,000 cycles
wait_1_second:
	push i
	push j
	push k
	push l
	ldi i, 0x09 ; load 9
	loop_i_wait_1_second:
		rcall wait_100_milliseconds
		dec i
		breq end_i_wait_1_second
		rjmp loop_i_wait_1_second
	end_i_wait_1_second: ; 9 * 1,600,007 - 1 = 14400064
	clz ; clear zero flag
	ldi j, 0x63 ; load 99
	loop_j_wait_1_second:
		rcall wait_1_millisecond
		dec j
		breq end_j_wait_1_second
		rjmp loop_j_wait_1_second
	end_j_wait_1_second: ; 99 * 16,007 - 1 = 1584692
	clz ; clear zero flag
	ldi k, 0x5b ; load 91
	loop_k_wait_1_second:
		rcall wait_10_microseconds
		dec k
		breq end_k_wait_1_second
		rjmp loop_k_wait_1_second
	end_k_wait_1_second: ; 91 * 167 - 1 = 15196
	clz ; clear zero flag
	ldi l, 0x05 ; load 5
	loop_l_wait_1_second:
		dec l
		breq end_l_wait_1_second
		rjmp loop_l_wait_1_second
	end_l_wait_1_second: ; 5 * 4 - 1 = 19
	clz ; clear zero flag
	nop
	pop l
	pop k
	pop j
	pop i
	ret