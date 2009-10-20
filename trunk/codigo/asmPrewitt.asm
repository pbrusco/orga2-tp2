%include "macros_imagenes.asm"

;void asmPrewitt(const char* src, char* dst, int ancho, int alto, int wstep)

global asmPrewitt

section .data
	

section .text

asmPrewitt:

	convC_push								; preservo los registros de la Convención C y creo el stack frame
	
	

	convC_pop								; restauro los registros de la Convención C y destruyo el stack frame
	ret										; regreso de la función llamada
