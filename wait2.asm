/*
 * wait2.asm
 *
 *  Created: 2/19/2019 2:20:32 PM
 *   Author: Benjamin Garcia
 */ 

.def i=r16
.def j=r17
.def k=r18

; void wait_1_second();
; waits 1 second (16,000,000 cycles)
; 16,000,000 = 3i + 3ij + 4ijk + 15 + c (c is potential NOPs)
; 15,999,985 = 3i + 3ij + 4ijk + c
wait_1_second:
	; pushing = 6 cycles
	push i
	push j
	push k

	ldi i, 0xff ; load 255
	loop_i_wait_1_second: ; 3i + 3ij + 4ijk - 2
		ldi j, 0xff ; load 255
		loop_j_wait_1_second: ; 3j + 4jk - 2
			ldi k, 0xff ; load 255
			loop_k_wait_1_second: ; 4k - 2
				dec k 
				breq end_k_wait_1_second 
				rjmp loop_k_wait_1_second ; 2 cycles (not executed on last iter)
			end_k_wait_1_second:
			dec j
			breq end_j_wait_1_second
			rjmp loop_j_wait_1_second ; 2 cycles (not executed on last iter)
		end_j_wait_1_second:
		dec i
		breq end_i_wait_1_second
		rjmp loop_i_wait_1_second ; 2 cycles (not executed on last iter)
	end_i_wait_1_second:

	; popping and return = 10 cycles
	pop k
	pop j
	pop i
	ret
