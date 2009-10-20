%include "macros.asm"

;void asmFreiChen(const char* src, char* dst, int ancho, int alto, int wstep)

global asmFreiChen

section .data
	
	%define DIR_SRC						[ebp+8]
	%define DIR_DST						[ebp+12]
	%define WIDTH						[ebp+16]
	%define HEIGHT						[ebp+20]
	%define WIDTH_STEP					[ebp+24]


-1 0 1		-1	-*	-1
-* 0 *		0	0	0
-1 0 1		1 	*	1

	%define NEGRO_ABS					0x00	
	%define BLANCO_ABS					0xFF

section .text

asmFreiChen:

	convC_push								; preservo los registros de la Convención C y creo el stack frame
	
	mov ebx, HEIGHT							; cargo en EBX la altura de la imagen y le resto 2
	sub ebx, 2

	mov ecx, WIDTH							; cargo en ECX el ancho de la imagen y le resto 2
	sub ecx, 2
	
	mov edx, WIDTH_STEP						; cargo en EDX el ancho de la imagen (con basura)
	
	mov esi, DIR_SRC						; cargo en ESI el puntero a la imagen fuente
	mov edi, DIR_DST						; cargo en EDI el puntero a la imagen destino
	lea edi, [edi+edx+1]					; muevo el puntero a la imagen destino 1 fila hacia abajo y 1 columna a la derecha
	

	aplicar_Mascara_A_Imagen:

		recorrer_fila:
				push ebx
				push ecx				

				mov eax, SOBEL_X				; analizo se se pidió hacer Sobel en la componente X
				cmp eax, 1						
				jne ejeY						; si no se pidió, hago Sobel en la componente y
			
				mov eax, SOBEL_Y				; analizo si se pidió hacer Sobel en la componente Y
				cmp eax, 1
				jne ejeX						; si no se pidió, hago Sobel en la componente X
												; si se pidieron ambos, hago Sobel en X e Y

				sobelXY							; macro de Sobel en las componentes X e Y
				jmp seguir
			
			ejeX:								; macro de Sobel en la componente X
				sobelX
				jmp seguir
	
			ejeY:								; macro de Sobel en la componente Y
				sobelY
			
			seguir:	
				pop ecx
				pop ebx
				mov [edi], al					; guardo el byte resultante en la posición apuntada por EDI
				inc edi							; corro el puntero EDI 1 columna a la derecha
				inc esi							; corro el puntero ESI 1 columna a la derecha
			
				dec ecx							; decremento el contador de columnas
				cmp ecx, 0						; evaluo si ya recorrí el ancho de la imágen
				jg recorrer_fila				; si no llegué al final reinicio el ciclo, sino continuo


		mov byte [edi], NEGRO_ABS			; pongo el último pixel de la fila en negro		

		mov ecx, WIDTH						; cargo en ECX el ancho de la imagen y le resto 2
		sub ecx, 2
		
		sub esi, ecx						; corro el puntero ESI al inicio de la fila
		lea esi, [esi+edx]					; corro el puntero ESI 1 fila hacia abajo
		
		sub edi, ecx						; corro el puntero EDI al inicio de la fila
		mov byte [edi], NEGRO_ABS			; pongo el primer pixel de la fila en negro
		lea edi, [edi+edx]					; corro el puntero EDI 1 fila hacia abajo

				
		dec ebx								; decremento el contador de filas recorridas
		cmp ebx, 0							; analizo si ya recorrí el alto de la imagen
		jg aplicar_Mascara_A_Imagen			; si llegué al final, salgo de la subrutina, sino reinicio el ciclo

	convC_pop								; restauro los registros de la Convención C y destruyo el stack frame
	ret										; regreso de la función llamada
