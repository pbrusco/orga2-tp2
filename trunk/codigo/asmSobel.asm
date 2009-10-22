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

	mov esi, src				
	mov edi, dst				
	mov ecx, alto
	sub ecx, 1		;VER POR QUE ASI FUNCA!!! Y CON 2 TAMBIEN, PERO SI COMPARO CON SOBEL, CON 2 ME COMO LA ULTIMA LINEA
	mov eax, paso
	mov edx, ancho
	sub edx,8
	pxor xmm3,xmm3			;lo voy a usar como mascara para desempaquetar
	pxor xmm6,xmm6			;aca voy a almacenar el resultado de hacer sobelX
	pxor xmm7,xmm7			;aca voy a almacenar el resultado de hacer sobelY


	recorroFilas:

		xor ebx, ebx				;pongo en 0 el contador de pixeles procesados
		
		
		recorroColumnas:
			pxor xmm5,xmm5			;aca voy a almacenar el resultado de hacer el sobel que me pidieron
			cmp ebx, edx			;me fijo si estoy terminando la fila
			jg procesoLosUltimosDeLaFila

		veoSiHagoSobelX:
			cmp dword xorder, 1			;veo si tengo que hacer sobelX
			jne hagoSobelY
		hagoSobelX:
			jmp sobelX				;deja en xmm6 el resultado de hacer sobelX
		veoSiHagoSobelY:
			cmp dword yorder, 1
			jne sigoColumnas
		hagoSobelY:
			jmp sobelY				;deja el resultado en xmm7

		sigoColumnas:
			paddusb xmm5, xmm6
			paddusb xmm5, xmm7
			movq [edi+eax+1],xmm5

			cmp ebx, edx
			jg sigoFilas			;si estoy procesando los ultimos, acomodo indices para saltar de fila

			lea esi,[esi+6]
			lea edi,[edi+6]
			add ebx,6
			jmp recorroColumnas

	sigoFilas:
		
		sub esi, edx ;hacemos esi -( ancho - 8) 	
		add esi, eax ;esi = esi + paso

		sub edi, edx ;hacemos edi -( ancho - 8) 	
		add edi, eax ;edi = edi + paso
		dec ecx
		cmp ecx, 0
		jne recorroFilas



	fin:
	
		convC_pop
		ret	






procesoLosUltimosDeLaFila:

	add esi,edx
	sub esi,ebx
	add edi,edx
	sub edi,ebx
	jmp veoSiHagoSobelX








sobelX:
		;esi apunta a la imagen fuente, al pixel donde debo empezar a cargar los datos a procesar
		
		movq xmm0,[esi]
		movq xmm1,[esi+eax]
		movq xmm2,[esi+eax*2]

		punpcklbw xmm0,xmm3
		punpcklbw xmm1,xmm3
		punpcklbw xmm2,xmm3

		paddusw xmm0,xmm1
		paddusw xmm0,xmm1
		paddusw xmm0,xmm2

		movdqu xmm1,xmm0
	
		psrldq xmm1,4
	
		psubusw xmm1,xmm0

		PACKUSWB xmm1,xmm1
		PSLLQ xmm1,16		
		PSRLQ xmm1,16
		movdqu xmm6, xmm1
		
		jmp veoSiHagoSobelY






sobelY:
		;esi apunta a la imagen fuente, al pixel donde debo empezar a cargar los datos a procesar
		
		movq xmm0,[esi]
		movq xmm1,[esi+eax]
		movq xmm2,[esi+eax*2]

		punpcklbw xmm0,xmm3
		punpcklbw xmm1,xmm3
		punpcklbw xmm2,xmm3

		paddusw xmm0,xmm1
		paddusw xmm0,xmm1
		paddusw xmm0,xmm2

		movdqu xmm1,xmm0
	
		psrldq xmm1,4
	
		psubusw xmm1,xmm0

		PACKUSWB xmm1,xmm1
		PSLLQ xmm1,16		
		PSRLQ xmm1,16
		movdqu xmm6, xmm1
		
		jmp sigoColumnas