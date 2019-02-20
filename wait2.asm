/*
 * wait2.asm
 *
 *  Created: 2/19/2019 2:20:32 PM
 *   Author: Benjamin Garcia
 */ 

.def i=r19
.def j=r20
.def k=r21

rjmp end_wait_2_asm

; void wait_1_second();
; waits 1 second (16,000,000 cycles)
; 16,000,000 = 4i + 4ij + 4ijk +16
wait_1_second:
	; pushing = 6 cycles
	push i
	push j
	push k

	ldi i, 0x6c ; load 108
	loop_i_wait_1_second: ; 4i + 4ij + 4ijk - 1 
		ldi j, 0xbc ; load 188
		loop_j_wait_1_second: ; 4j + 4jk - 1
			ldi k, 0xc4 ; load 196
			loop_k_wait_1_second: ; 4k - 1
				dec k 
				breq end_k_wait_1_second ; 1 cycle (2 on last iter)
				rjmp loop_k_wait_1_second ; 2 cycles (not executed on last iter)
			end_k_wait_1_second:
			dec j
			breq end_j_wait_1_second ; 1 cycle (2 on last iter)
			rjmp loop_j_wait_1_second ; 2 cycles (not executed on last iter)
		end_j_wait_1_second:
		dec i
		breq end_i_wait_1_second ; 1 cycle (2 on last iter)
		rjmp loop_i_wait_1_second ; 2 cycles (not executed on last iter)
	end_i_wait_1_second:

	; popping and return = 10 cycles
	pop k
	pop j
	pop i
	ret

end_wait_2_asm: