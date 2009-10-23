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


;	x			y

;-1 0 1		-1	-*	-1
;-* 0 *		0	0	0
;-1 0 1		1 	*	1


section .text

asmFreiChen:

	convC_push								; preservo los registros de la Convención C y creo el stack frame
	
	mov eax, HEIGHT							; EAX = HEIGHT
	mov ecx, WIDTH_STEP						; ECX = WIDTH_STEP
	mul ecx
	mov ecx, eax							; ECX = HEIGHT * WIDTH_STEP

	mov esi, DIR_SRC						; ESI = puntero a la matriz fuente
	mov edi, DIR_DST						; EDI = puntero a la matriz destino
	
	mov eax, WIDTH							; EAX = WIDTH
	
	xor xmm0, xmm0
	
	ciclo: 
		
		movd xmm1, [esi]					; xmm1 = p1_3|p1_2|p1_1|p1_0  (p* = 8bits)
		movd xmm2, [esi+eax]				; xmm2 = p2_3|p2_2|p2_1|p2_0  (p* = 8bits)
		movd xmm3, [esi+eax*2]				; xmm3 = p3_3|p3_2|p3_1|p3_0  (p* = 8bits)


		; desempaqueto los 4 píxeles de cada una de las 3 filas de bytes a word, y luego de word a doubleword
		
		punpcklbw xmm1, xmm0				; xmm1 = p1_3|p1_2|p1_1|p1_0	(p* = 16 bits)
		punpcklwd xmm1, xmm0				; xmm1 = p1_3|p1_2|p1_1|p1_0 	(p* = 32 bits)

		punpcklbw xmm2, xmm0				; xmm2 = p2_3|p2_2|p2_1|p2_0	(p* = 16 bits)
		punpcklwd xmm2, xmm0				; xmm2 = p2_3|p2_2|p2_1|p2_0	(p* = 32 bits)

		punpcklbw xmm3, xmm0				; xmm3 = p3_3|p3_2|p3_1|p3_0	(p* = 16 bits)
		punpcklwd xmm3, xmm0				; xmm3 = p3_3|p3_2|p3_1|p3_0	(p* = 32 bits)


		; cargo en XMM4 4 veces la raíz cuadrada de 2

		movss xmm4, 2						; xmm4 = 2
		pshufd xmm4, xmm4, 00000000b		; xmm4 = 2|2|2|2
		sqrtps	xmm4, xmm4					; xmm4 = 2*|2*|2*|2*

		movdqu xmm5, xmm4					; xmm5 = xmm4
		movdqu xmm6, xmm4					; xmm6 = xmm6

		; aplico la máscara de Frei-Chen en Y para a los píxeles p2_2 y p2_1

		movdqu xmm7, xmm3					; xmm7 = xmm3
		paddd xmm7, xmm1					; xmm7 = p3_3 + p1_3 | p3_2 + p1_2 | p3_1 + p1_1 | p3_0 + p1_0
		mulps xmm5, xmm1					; xmm5 = 2^½.p1_3| 2^½.p1_2 | 2^½.p1_1 | 2^½.p1_0
		mulps xmm6, xmm1					; xmm6 = 2^½.p3_3| 2^½.p3_2 | 2^½.p3_1 | 2^½.p3_0

		pshufd xmm5, xmm5, 00000000b		; xmm5 = 2^½.p1_3| 2^½.p1_2 | 2^½.p1_1 | 2^½.p1_0

		; aplico la máscara de Frei-Chen en X para a los píxeles p2_2 y p2_1
		
		
	convC_pop								; restauro los registros de la Convención C y destruyo el stack frame
	ret										; regreso de la función llamada
