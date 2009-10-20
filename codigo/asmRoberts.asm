%include "macros_imagenes.asm"

;void asmRoberts(const char* src, char* dst, int ancho, int alto, int wstep)

global asmRoberts

section .data


section .text

asmRoberts:
	convC_push								; preservo los registros de la Convención C y creo el stack frame
	
	
	convC_pop								; restauro los registros de la Convención C y destruyo el stack frame
	ret										; salgo de la llamada a la ejecución
