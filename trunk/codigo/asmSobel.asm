%include "macros.asm"

;void asmSobel(const char* src, char* dst, int ancho, int alto, int wstep, int xorder, int yorder)

global asmSobel

section .data

%define src [ebp+8]
%define dst [ebp+12]
%define ancho [ebp+16]
%define alto [ebp+20]
%define paso [ebp+24]
%define xorder [ebp+28]
%define yorder [ebp+32]




section .text

asmSobel:

	convC_push				

	mov esi, src			;cargo en esi el puntero a la imagen fuente		
	mov edi, dst			;cargo en edi el puntero a la imagen destino	
	mov ecx, alto
	sub ecx, 2			;ecx = alto - 2 (porque tanto la primera como la ultima fila no las proceso)
	mov eax, paso			;en eax dejo el tamaño del ancho de la imagen (con basura)
	mov edx, ancho			
	sub edx,8			;edx = ancho - 8 (lo voy a usar para iterar sobre cada fila de la imagen)
	pxor xmm3,xmm3			;lo voy a usar como mascara para desempaquetar
	pxor xmm6,xmm6			;aca voy a almacenar el resultado de hacer sobelX
	pxor xmm7,xmm7			;aca voy a almacenar el resultado de hacer sobelY


	recorroFilas:

		xor ebx, ebx				;lo voy a usar para contar los pixeles procesados
		
		
		recorroColumnas:
			pxor xmm5,xmm5			;aca voy a almacenar el resultado de aplicar el operador de sobel que me pidieron
			cmp ebx, edx			;me fijo si estoy terminando la fila
			jg acomodoIndices		;si estoy al final de la fila, acomodo los punteros para poder procesar los ultimos pixeles

		veoSiHagoSobelX:
			cmp dword xorder, 1		;veo si tengo que hacer sobelX
			jne hagoSobelY
		hagoSobelX:
			jmp sobelX			;deja en xmm6 el resultado de hacer sobelX
		veoSiHagoSobelY:
			cmp dword yorder, 1
			jne sigoColumnas
		hagoSobelY:
			jmp sobelY			;deja en xmm7 el resultado de hacer sobelY

		sigoColumnas:
			paddusb xmm5, xmm6		;sumo a xmm5 el resultado de sobelX (sumo 0 en caso de no tener que hacer sobelX) 
			paddusb xmm5, xmm7		;sumo a xmm5 el resultado de sobelY (sumo 0 en caso de no tener que hacer sobelY) 
			movq [edi+eax+1],xmm5		;guardo el resultado en las posiciones que corresponden

			cmp ebx, edx
			jg sigoFilas			;si acabo de procesar los ultimos pixeles de la fila, acomodo indices para cambiar de fila

			lea esi,[esi+6]			;hago que esi apunte a los proximos 6 pixeles a procesar
			lea edi,[edi+6]			;acomodo edi para guardar los proximos resultados
			add ebx,6			;agrego 6 al contador de pixeles pixeles procesados
			jmp recorroColumnas		;sigo recorriendo la misma fila

	sigoFilas:
		
		sub esi, edx 		;hacemos esi -( ancho - 8)
		add esi, eax 		;esi = esi + paso (esi apunta al comienzo de la siguiente fila)

		sub edi, edx 		;hacemos edi -( ancho - 8) 	
		add edi, eax		;edi = edi + paso (edi apunta al comienzo de la siguiente fila)
		dec ecx			;decremento el contador de filas
		cmp ecx, 0		;veo si termine de procesar la imagen
		jne recorroFilas	;si no termine, paso a procesar la fila que sigue



	fin:
	
		convC_pop
		ret	






acomodoIndices:

	add esi,edx
	sub esi,ebx			;dejo a esi apuntando a los ultimos 8 pixeles de la fila actual
	add edi,edx
	sub edi,ebx			;dejo a edi apuntando a los ultimos 8 pixeles de la fila actual
	jmp veoSiHagoSobelX		;una vez acomodado los indices, proceso los ultimos 6 pixeles de la fila actual








sobelX:
		;esi apunta a la imagen fuente, al pixel donde debo empezar a cargar los datos a procesar
		;no pisar xmm3, xmm5, xmm7

		movq xmm0,[esi]			;cargo en la parte menos significativa de xmm0, la primer tira de pixeles
		movq xmm1,[esi+eax]		;cargo en la parte menos significativa de xmm1, la segunda tira de pixeles
		movq xmm2,[esi+eax*2]		;cargo en la parte menos significativa de xmm2, la tercer tira de pixeles

		punpcklbw xmm0,xmm3		;desempaqueto de byte a word la parte menos significativa de xmm0
		punpcklbw xmm1,xmm3		;desempaqueto de byte a word la parte menos significativa de xmm1
		punpcklbw xmm2,xmm3		;desempaqueto de byte a word la parte menos significativa de xmm2


		paddusw xmm0,xmm1
		paddusw xmm0,xmm1
		paddusw xmm0,xmm2		;xmm0 = xmm0 + 2* xmm1 + xmm2

		movdqu xmm1,xmm0		;copio xmm0
	
		psrldq xmm1,4			;shifteo 2 words a derecha xmm1
	
		psubusw xmm1,xmm0		;luego de esta resta, me quedan en los 6 bytes menos significativos 
						;de xmm1 el resultado de sobelX

		PACKUSWB xmm1,xmm1		;empaqueto xmm1 para poder guardar el resultado
		PSLLQ xmm1,16
		PSRLQ xmm1,16			;shifteo 2 bytes a izquierda y derecha a xmm1 para dejar 0's en los 2 bytes
						;mas significativos de ambas qwords del registro, para guardar los 8 bytes
						;directamente en la imagen destino, sin preocuparme de guardar basura

		movdqu xmm6, xmm1		;dejo el resultado de hacer sobelX en xmm6
		
		jmp veoSiHagoSobelY		;me fijo si tengo que usar el operador sobelY






sobelY:
		;esi apunta a la imagen fuente, al pixel donde debo empezar a cargar los datos a procesar
		;no pisar xmm3, xmm5, xmm6

		movq xmm0,[esi]			;cargo en la parte menos significativa de xmm0, la primer tira de pixeles
		movq xmm1,[esi+eax*2]		;cargo en la parte menos significativa de xmm1, la tercer tira de pixeles
		

		punpcklbw xmm0,xmm3		;desempaqueto de byte a word la parte menos significativa de xmm0
		punpcklbw xmm1,xmm3		;desempaqueto de byte a word la parte menos significativa de xmm1
		
		movdqu xmm2, xmm0		;copio xmm0 en xmm2
		movdqu xmm4, xmm0		;copio xmm0 en xmm4
		psrldq xmm2, 2			;shifteo xmm2 1 word a derecha
		psrldq xmm4, 4			;shifteo xmm4 2 words a derecha
		paddusw xmm0,xmm2		
		paddusw xmm0,xmm2
		paddusw xmm0,xmm4		;dejo en las 6 words menos significativas de xmm0 el resultado de aplicar
						;la primer fila de la mascara de sobelY

		movdqu xmm2, xmm1		;copio xmm1 en xmm2
		movdqu xmm4, xmm1		;copio xmm1 en xmm4
		psrldq xmm2, 2			;shifteo xmm2 1 word a derecha
		psrldq xmm4, 4			;shifteo xmm2 2 words a derecha
		paddusw xmm1,xmm2
		paddusw xmm1,xmm2
		paddusw xmm1,xmm4		;dejo en las 6 words menos significativas de xmm1 el resultado de aplicar
						;la tercer fila de la mascara de sobelY


		psubusw xmm1, xmm0 		;hago la suma final, es decir, aplico completamente la mascara de sobelY


		PACKUSWB xmm1,xmm1		;empaqueto xmm1 para poder guardar el resultado
		PSLLQ xmm1,16		
		PSRLQ xmm1,16			;shifteo 2 bytes a izquierda y derecha a xmm1 para dejar 0's en los 2 bytes
						;mas significativos de ambas qwords del registro, para guardar los 8 bytes
						;directamente en la imagen destino, sin preocuparme de guardar basura

		movdqu xmm7, xmm1		;dejo el resultado de hacer sobelY en xmm7
		
		jmp sigoColumnas		;paso a acomodar los indices para la proxima iteracion
