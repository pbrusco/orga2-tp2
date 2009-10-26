;void asmFreiChen(const char* src, char* dst, int ancho, int alto, int wstep)

%include "macros.asm"

global asmFreiChen


section .data
	
	%define DIR_SRC						[ebp+8]
	%define DIR_DST						[ebp+12]
	%define WIDTH						[ebp+16]
	%define HEIGHT						[ebp+20]
	%define WIDTH_STEP					[ebp+24]
	%define var_local_1					[ebp-4]

	

section .text

asmFreiChen:

	; preservo los registros de la Convención C y creo el stack frame

	convC_push 4


	; cargo en los registros de propósito general las dimensiones de la matriz

	mov eax, HEIGHT				; eax = HEIGHT
	sub eax, 2				; eax = HEIGHT-2
	mov ecx, WIDTH				; ecx = WIDTH

	mul ecx
	mov ecx, eax				; ecx = (HEIGHT-2) * (WIDTH-2)
	shr ecx, 1				; ecx = (HEIGHT-2) * (WIDTH-2)/2 -- voy a procesar 2 píxeles por vez
	mov eax, WIDTH				; eax = WIDTH
	
	
	; cargo en los registros ESI y EDI las direcciones de memoria de las matrices

	mov esi, DIR_SRC			; esi = puntero a la matriz fuente
	mov edi, DIR_DST			; edi = puntero a la matriz destino
	
		
	; calculo la raiz cuadrada de 2 con la FPU y la guardo en var_local_1

	finit					; inicializo la FPU
	fld1					; st0 = 1
	fadd st0				; st0 = 2
	fsqrt					; st0 = 2^½	
	fstp dword var_local_1			; var_local_1 = 2^½

	
	; a continuación, en el ciclo que sigue recorro la matriz aplicando la máscara de a 2 píxeles por vez
	
;---------------------------------------------------------------------------------------------------------------------
; ACLARACIÓN: En la representación utilizada para seguir el algoritmo, los píxeles en los registros quedan invertidos 
; respecto a su posición en la matriz, es decir, en la matriz la numeración de los píxeles crece de izquierda a 
; derecha, mientras que en los registros xmm la numeración de los píxeles crece de derecha a izquierda

; ACLARACIÓN 2: Los pixeles de la matriz se indexan como pij, donde i = fila (1 a HEIGHT) y j = columna (0 a WHIDTH)
; --------------------------------------------------------------------------------------------------------------------

	.ciclo: 

		; cargo en los registros XMM1, XMM2 y XMM3 4 píxeles de 3 filas contínuas de la matriz fuente	
		
		pxor xmm0, xmm0			; xmm0 = 0 
		pxor xmm6, xmm6			; xmm6 = 0
		
		movd xmm1, [esi]		; xmm1 = p13|p12|p11|p10  (p* = 8 bits int)
		movd xmm2, [esi+eax]		; xmm2 = p23|p22|p21|p20  (p* = 8 bits int)
		movd xmm3, [esi+eax*2]		; xmm3 = p33|p32|p31|p30  (p* = 8 bits int)


		; desempaqueto los 4 píxeles de cada una de las 3 filas de bytes a word, y luego de word a doubleword
		
		punpcklbw xmm1, xmm0		; xmm1 = p13|p12|p11|p10  (p* = 16 bits int)
		punpcklwd xmm1, xmm0		; xmm1 = p13|p12|p11|p10  (p* = 32 bits int)

		punpcklbw xmm2, xmm0		; xmm2 = p23|p22|p21|p20  (p* = 16 bits int)
		punpcklwd xmm2, xmm0		; xmm2 = p23|p22|p21|p20  (p* = 32 bits int)

		punpcklbw xmm3, xmm0		; xmm3 = p33|p32|p31|p30  (p* = 16 bits int)
		punpcklwd xmm3, xmm0		; xmm3 = p33|p32|p31|p30  (p* = 32 bits int)


		; convierto los valores de los 4 píxeles de cada una de las 3 filas de enteros a punto flotante sp

		cvtdq2ps xmm1, xmm1		; xmm1 = p13|p12|p11|p10  (p* = 32 bits float)
		cvtdq2ps xmm2, xmm2		; xmm2 = p23|p22|p21|p20  (p* = 32 bits float)
		cvtdq2ps xmm3, xmm3		; xmm3 = p33|p32|p31|p30  (p* = 32 bits float)


		; cargo en XMM4 4 veces la raíz cuadrada de 2 y luego lo copio en XMM5

		movss xmm4, var_local_1		; xmm4 =     |     |     | 2^½		
		pshufd xmm4, xmm4, 00000000b	; xmm4 = 2^½ | 2^½ | 2^½ | 2^½

		movdqu xmm5, xmm4		; xmm5 = xmm4


		; aplico la máscara de Frei-Chen en X para a los píxeles p22 y p21

		subps xmm6, xmm3		; xmm6 = -p33|-p32|-p31|-p30
		subps xmm6, xmm1		; xmm6 = -p33-p13|-p32-p12|-p31-p11|-p30-p10

		movdqu xmm7, xmm3		; xmm3 =  p33|p32|p31|p30
		addps xmm7, xmm1		; xmm7 =  p33+p13| p32+p12| p31+p11| p30+p10

		pshufd xmm7, xmm7, 11111110b	; xmm7 =  p33+p13| p33+p13| p33+p13| p32+p12

		mulps xmm2, xmm4		; xmm4 =  p23*2^½ | p22*2^½ | p21*2^½ | p20*2^½
		pshufd xmm0, xmm4, 11111110b	; xmm0 =  p23*2^½ | p23*2^½ | p23*2^½ | p22*2^½ 
		
		subps xmm0, xmm4		; xmm0 =  - | - | p23*2^½ - p21*2^½ | p22*2^½ - p20*2^½
		addps xmm0, xmm6		; xmm0 =  - | - | (p23-p21)*2^½ -p31 -p11 | (p22-p20)*2^½ -p30 -p10
		addps xmm0, xmm7		; xmm0 =  - | - | Frey-ChenX(p22) | Frey-ChenX(p21)

		pxor mm0, mm0			; mm0 = 0
		cvtps2pi mm0, xmm0		; mm0 = Frey-ChenX(p22) | Frey-ChenX(p21)  (32 bits int c/u)


		; aplico la máscara de Frei-Chen en Y para a los píxeles p22 y p21

		mulps xmm4, xmm1		; xmm4 =  p13*2^½ | p12*2^½ | p11*2^½ | p10*2^½		
		pshufd xmm4, xmm4, 11111001b	; xmm4 =  p13*2^½ | p13*2^½ | p13*2^½ | p12*2^½ 
		
		mulps xmm5, xmm3		; xmm5 =  p33*2^½ | p32*2^½ | p31*2^½ | p30*2^½		
		pshufd xmm5, xmm5, 11111001b	; xmm5 =  p33*2^ ½ | p33*2^½ | p33*2^½ | p32*2^½ 
		
		subps xmm1, xmm3		; xmm1 =  p33-p13| p32-p12| p31-p11| p30-p10
		pshufd xmm3, xmm1, 11111110b	; xmm3 =  p33-p13| p33-p13| p33-p13| p32-p12

		addps xmm1, xmm3		; xmm1 =  - | - | p31-p11+p33-p13| p30-p10+p32-p12
		addps xmm1, xmm5		; xmm1 =  - | - | p31-p11+p33-p13+p33*2^½ | p30-p10+p32-p12+p32*2^½
		subps xmm1, xmm4		; xmm1 =  - | - | Frey-ChenY(p22) | Frey-ChenY(p21)
		
		pxor mm1, mm1			; mm1 = 0
		cvtps2pi mm1, xmm1		; mm1 = Frey-ChenY(p22) | Frey-ChenY(p21)  (32 bits int c/u)
		

		; empaqueto los pixeles procesado en X e Y en los registros XMM0 y XMM1 a words  primero, luego a bytes 
		; y finalmente realizo la suma empaquetada y con saturación de ambos
	
		packssdw mm0, mm0		; mm0 = - | - | Frey-ChenX(p22) | Frey-ChenX(p21)  (16 bits int c/u)
		packsswb mm0, mm0		; mm0 = - | - | - | - | Frey-ChenX(p22) | Frey-ChenX(p21)(8bits int c/u)

		packssdw mm1, mm1		; mm1 = - | - | Frey-ChenY(p22) | Frey-ChenY(p21)  (16 bits int c/u)
		packsswb mm1, mm1		; mm1 = - | - | - | - | Frey-ChenY(p22) | Frey-ChenY(p21)(8bits int c/u)

		paddsb mm0, mm1			; mm0 = - | - | - | - | Frey-ChenXY(p22) | Frey-ChenXY(p21)
		
		
		; guardo los píxeles procesados en la matriz destino y avanzo los punteros para continuar el procesando
		
		movd [edi+eax+1], mm0		; guardo los 2 píxeles procesados en la matriz destino

		lea esi, [esi+2]		; avanzo el puntero en la matriz fuente 2 píxeles a la derecha
		lea edi, [edi+2]		; avanzo el puntero en la matriz destino 2 píxeles a la derecha		
		
		dec ecx				; decremento en 1 el contador de píxeles procesados
		jnz .ciclo			; repito el ciclo hasta haber procesado todos los píxeles de la imagen
 
	; restauro los registros de la Convención C y destruyo el stack frame
	
	convC_pop 4			
	
	
	; regreso de la llamada a la función
	
	ret					

