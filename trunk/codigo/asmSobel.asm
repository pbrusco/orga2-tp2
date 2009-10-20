%include "macros_imagenes.asm"

;void asmSobel(const char* src, char* dst, int ancho, int alto, int wstep, int xorder, int yorder)

global asmSobel

section .data
	

section .text

asmSobel:

	convC_push								; preservo los registros de la Convención C y creo el stack frame
	
	

	convC_pop								; restauro los registros de la Convención C y destruyo el stack frame
	ret										; regreso de la función llamada
