%include "macros.asm"

;void asmFreiChen(const char* src, char* dst, int ancho, int alto, int wstep)

global asmFreiChen

section .data
	
	%define DIR_SRC						[ebp+8]
	%define DIR_DST						[ebp+12]
	%define WIDTH						[ebp+16]
	%define HEIGHT						[ebp+20]
	%define WIDTH_STEP					[ebp+24]
	%define NEGRO_ABS					0x00	
	%define BLANCO_ABS					0xFF


	x			y

-1 0 1		-1	-*	-1
-* 0 *		0	0	0
-1 0 1		1 	*	1


section .text

asmFreiChen:

	convC_push								; preservo los registros de la Convención C y creo el stack frame
	


	convC_pop								; restauro los registros de la Convención C y destruyo el stack frame
	ret										; regreso de la función llamada
