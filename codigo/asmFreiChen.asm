;void asmFreiChen(const char* src, char* dst, int ancho, int alto, int wstep)

%include "macros.asm"

global asmFreiChen


section .data
	
	%define DIR_SRC						[ebp+8]
	%define DIR_DST						[ebp+12]
	%define WIDTH						[ebp+16]
	%define HEIGHT						[ebp+20]
	%define WIDTH_STEP					[ebp+24]

	
section .text

asmFreiChen:

	; preservo los registros de la Convención C y creo el stack frame

	convC_push


	; cargo XMM4 4 veces con el entero 2, convierto cada paquete en un flotante y le calculo la raiz cuadrada

	mov dword eax, 2		; eax = 2 
	movd xmm4, eax			; xmm4 = - | - | - | 2		(32 bits inc c/u)
	pshufd xmm4, xmm4, 00000000b	; xmm4 = 2 | 2 | 2 | 2		(32 bits inc c/u)
	cvtdq2ps xmm4, xmm4		; xmm4 = 2 | 2 | 2 | 2		(32 bits float c/u)
	sqrtps xmm4, xmm4		; xmm4 = 2^½ | 2^½ | 2^½ | 2^½	(32 bits float c/u)
	
	
	; cargo en los registros de propósito general las dimensiones de la matriz

	mov ebx, HEIGHT				; ebx = HEIGHT
	sub ebx, 2				; ebx = HEIGHT-2 	-- hay 2 filas que no proceso
	mov edx, WIDTH				; edx = WIDTH
	
	
	; cargo en ECX la cantidad de procesamientos de píxeles que tengo que hacer por fila

	mov ecx, WIDTH_STEP			; ecx = WIDTH_STEP 	-- no proceso los bytes de relleno
	sub ecx, 2				; ecx = WIDTH_STEP-2 	-- hay 2 columnas que no proceso
	shr ecx, 1				; ecx = (WIDTH-2)/2 	-- voy a procesar 2 píxeles por vez
		

	; cargo en los registros ESI y EDI las direcciones de memoria de las matrices
	
	mov esi, DIR_SRC			; esi = puntero a la matriz fuente
	mov edi, DIR_DST			; edi = puntero a la matriz destino
	

	; a continuación, en el ciclo que sigue recorro la matriz aplicando la máscara de a 2 píxeles por vez
	
;---------------------------------------------------------------------------------------------------------------------
; ACLARACIÓN: En la representación utilizada para seguir el algoritmo, los píxeles en los registros quedan invertidos 
; respecto a su posición en la matriz, es decir, en la matriz la numeración de los píxeles crece de izquierda a 
; derecha, mientras que en los registros xmm la numeración de los píxeles crece de derecha a izquierda

; ACLARACIÓN 2: Los pixeles de la matriz se indexan como pij, donde i = fila (1 a HEIGHT-2) y j = columna (0 a WHIDTH)
; --------------------------------------------------------------------------------------------------------------------

	.recorrerMatriz: 

	xor eax, eax				; eax = 0

		.recorrerFila:
	
		; cargo en los registros XMM1, XMM2 y XMM3 4 píxeles de 3 filas contínuas de la matriz fuente
		; y cargo los registros XMM5 y XMM6 con el contenido de XMM4
		
		pxor xmm0, xmm0			; xmm0 = 0 
		
		movd xmm1, [esi]		; xmm1 =  0|0|0|0|0|0|0|0|0|0|0|0|p13|p12|p11|p10  (p* = 8 bits int)
		movd xmm2, [esi+edx]		; xmm2 =  0|0|0|0|0|0|0|0|0|0|0|0|p23|p22|p21|p20  (p* = 8 bits int)
		movd xmm3, [esi+edx*2]		; xmm3 =  0|0|0|0|0|0|0|0|0|0|0|0|p33|p32|p31|p30  (p* = 8 bits int)

		movdqu xmm5, xmm4		; xmm5 = 2^½ | 2^½ | 2^½ | 2^½			   (32 bits float c/u)
		movdqu xmm6, xmm4		; xmm6 = 2^½ | 2^½ | 2^½ | 2^½			   (32 bits float c/u)


		; desempaqueto los 4 píxeles de cada una de las 3 filas de bytes a word, y luego de word a doubleword
		
		punpcklbw xmm1, xmm0		; xmm1 = 0|0|0|0|p13|p12|p11|p10  (p* = 16 bits int)
		punpcklwd xmm1, xmm0		; xmm1 = p13|p12|p11|p10	  (p* = 32 bits int)

		punpcklbw xmm2, xmm0		; xmm2 = 0|0|0|0|p23|p22|p21|p20  (p* = 16 bits int)
		punpcklwd xmm2, xmm0		; xmm2 = p23|p22|p21|p20	  (p* = 32 bits int)

		punpcklbw xmm3, xmm0		; xmm3 = 0|0|0|0|p33|p32|p31|p30  (p* = 16 bits int)
		punpcklwd xmm3, xmm0		; xmm3 = p33|p32|p31|p30	  (p* = 32 bits int)


		; convierto los valores de los 4 píxeles de cada una de las 3 filas de enteros a punto flotante sp

		cvtdq2ps xmm1, xmm1		; xmm1 = p13|p12|p11|p10  (p* = 32 bits float)
		cvtdq2ps xmm2, xmm2		; xmm2 = p23|p22|p21|p20  (p* = 32 bits float)
		cvtdq2ps xmm3, xmm3		; xmm3 = p33|p32|p31|p30  (p* = 32 bits float)


		; aplico la máscara de Frei-Chen en X para a los píxeles p22 y p21

		movdqu xmm7, xmm3		; xmm6 = p33|p32|p31|p30 
		mulps xmm2, xmm4		; xmm2 =  p23*2^½ | p22*2^½ | p21*2^½ | p20*2^½

		addps xmm7, xmm1		; xmm7 = p33+p13 | p32+p12 | p31+p11 | p30+p10		
		addps xmm7, xmm2		; xmm7 = p33+p13+p23*2^½|p32+p12+p22*2^½|p31+p11+p21*2^½|p30+p10+p20*2^½

		pshufd xmm0, xmm7, 11111110b	; xmm0 = p33+p13+p23*2^½|p33+p13+p23*2^½|p33+p13+p23*2^½|p32+p12+p22*2^½

		subps xmm0, xmm7		; xmm0 =  - | - | Frey-ChenX(p22) | Frey-ChenX(p21)


		; aplico la máscara de Frei-Chen en Y para a los píxeles p22 y p21

		mulps xmm5, xmm1		; xmm5 =  p13*2^½ | p12*2^½ | p11*2^½ | p10*2^½		
		pshufd xmm5, xmm5, 11111001b	; xmm5 =  p13*2^½ | p13*2^½ | p13*2^½ | p12*2^½ 
	
		mulps xmm6, xmm3		; xmm6 =  p33*2^½ | p32*2^½ | p31*2^½ | p30*2^½		
		pshufd xmm6, xmm6, 11111001b	; xmm6 =  p33*2^ ½ | p33*2^½ | p33*2^½ | p32*2^½ 

		subps xmm6, xmm5		; xmm6 =  - | - | (p33-p13)*2^½ | (p32-p12)*2^½ 

		subps xmm3, xmm1		; xmm3 =  p33-p13| p32-p12| p31-p11| p30-p10
		pshufd xmm1, xmm3, 11111110b	; xmm1 =  p33-p13| p33-p13| p33-p13| p32-p12
		addps xmm1, xmm3		; xmm1 =  - | - | p33-p13+p31-p11| p32-p12+p30-p10

		addps xmm1, xmm6		; xmm1 =  - | - | Frey-ChenY(p22) | Frey-ChenY(p21)		


		; saturo los píxeles procesados en la derivada X e Y guardados en XMM0 y XMM1 respectivamente
				
		pxor xmm2, xmm2			; xmm2 = 0
		cmpps xmm2, xmm0, 2		; xmm2 tiene FFFFh en aquellos paquetes que son negativos
		pand xmm0, xmm2			; los paquetes negativos de xmm0 son convertidos en 0

		pxor xmm2, xmm2			; xmm2 = 0
		cmpps xmm2, xmm1, 2		; xmm2 tiene FFFFh en aquellos paquetes que son negativos
		pand xmm1, xmm2			; los paquetes negativos de xmm1 son convertidos en 0


		; convierto los valores de los píxeles de punto flotante a enteros nuevamente
		
		pxor mm0, mm0			; mm0 = 0
		cvtps2pi mm0, xmm0		; mm0 = Frey-ChenX(p22) | Frey-ChenX(p21)  (32 bits int c/u)
				
		pxor mm1, mm1			; mm1 = 0
		cvtps2pi mm1, xmm1		; mm1 = Frey-ChenY(p22) | Frey-ChenY(p21)  (32 bits int c/u)


		; empaqueto los pixeles procesado en la derivada X e Y y guardados en MM0 y MM1 respectivamente a
		; words  primero, luego a bytes
	
		packssdw mm0, mm0		; mm0 = - | - | Frey-ChenX(p22) | Frey-ChenX(p21)  (16 bits int c/u)
		packsswb mm0, mm0		; mm0 = - | - | - | - | Frey-ChenX(p22) | Frey-ChenX(p21)(8bits int c/u)

		packssdw mm1, mm1		; mm1 = - | - | Frey-ChenY(p22) | Frey-ChenY(p21)  (16 bits int c/u)
		packsswb mm1, mm1		; mm1 = - | - | - | - | Frey-ChenY(p22) | Frey-ChenY(p21)(8bits int c/u)


		;finalmente realizo la suma empaquetada y con saturación de ambos para obtener los valores de los
		; píxeles en la derivada XY
		
		paddusb mm0, mm1			; mm0 = - | - | - | - | Frey-ChenXY(p22) | Frey-ChenXY(p21)
		

		; guardo los píxeles procesados en la matriz destino y avanzo los punteros para continuar el procesando
		
		movd [edi+edx+1], mm0		; guardo los 2 píxeles procesados en la matriz destino

		lea esi, [esi+2]		; avanzo el puntero en la matriz fuente 2 píxeles a la derecha
		lea edi, [edi+2]		; avanzo el puntero en la matriz destino 2 píxeles a la derecha		
		
		inc eax				; incremento el contador de procesamientos realizados
		cmp eax, ecx			; comparo con la cantidad de procesamientos a realizar por fila
		jne .recorrerFila		; repito el ciclo hasta haber procesado la cantidad predeterminada

	lea eax, [2*eax+4]			; eax = WIDTH_STEP

	sub esi, eax				; esi = puntero al inicio de la fila actual de la matriz fuente
	lea esi, [esi+edx]			; esi = puntero a la siguiente fila a recorrer en la matriz fuente
	sub edi, eax				; edi = puntero al inicio de la fila actual de la matriz destino
	lea edi, [edi+edx]			; edi = puntero a la siguiente fila a recorrer en la matriz destino

	dec ebx					; decremento el contador de filas por recorrer
	jnz .recorrerMatriz			; repito el ciclo hasta haber recorrido todas las filas de la matriz


	; restauro los registros de la Convención C y destruyo el stack frame
	
	convC_pop			
	
	
	; regreso de la llamada a la función
	
	ret					

