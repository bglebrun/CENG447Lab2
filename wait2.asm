/*
 * wait2.asm
 *
 *  Created: 2/19/2019 2:20:32 PM
 *   Author: Benjamin Garcia
 */ 

;.def i=r16
;.def j=r17
;.def k=r18

rjmp end_wait_2_asm

; void wait_1_second();
; waits 1 second (16,000,000 cycles)
; 16,000,000 = 4i + 4ij + 4ijk +16
wait_1_second:
	; pushing = 6 cycles
	push r16
	push r17
	push r18

	ldi r16, 0x6c ; load 108
	loop_i_wait_1_second: ; 4i + 4ij + 4ijk - 1 
		ldi r17, 0xbc ; load 188
		loop_j_wait_1_second: ; 4j + 4jk - 1
			ldi r18, 0xc4 ; load 196
			loop_k_wait_1_second: ; 4k - 1
				dec r18 
				breq end_k_wait_1_second ; 1 cycle (2 on last iter)
				rjmp loop_k_wait_1_second ; 2 cycles (not executed on last iter)
			end_k_wait_1_second:
			dec r17
			breq end_j_wait_1_second ; 1 cycle (2 on last iter)
			rjmp loop_j_wait_1_second ; 2 cycles (not executed on last iter)
		end_j_wait_1_second:
		dec r16
		breq end_i_wait_1_second ; 1 cycle (2 on last iter)
		rjmp loop_i_wait_1_second ; 2 cycles (not executed on last iter)
	end_i_wait_1_second:

	; popping and return = 10 cycles
	pop r18
	pop r17
	pop r16
	ret

end_wait_2_asm: