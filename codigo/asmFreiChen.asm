%include "macros.asm"

;extern void asmFreiChen(const char* src, char* dst, int ancho, int alto, int wstep)

global asmFreiChen

section .data



section .text


asmFreiChen:

	convC_push





	convC_pop
	ret
