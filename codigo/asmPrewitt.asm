%include "macros.asm"

%define src [ebp+8]
%define dst [ebp+12]
%define ancho [ebp+16]
%define alto [ebp+20]
%define paso [ebp+24]



;void asmPrewitt(const char* src, char* dst, int ancho, int alto, int wstep)

global asmPrewitt

section .data
	

section .text

asmPrewitt:


	convC_push				

	mov esi, src				
	mov edi, dst				
	mov ecx, alto
	sub ecx, 2
	mov eax, paso
	mov edx, ancho
	sub edx,8
	pxor xmm3,xmm3

	sobelX:

cicloFila:
	xor ebx,ebx
		
	cicloColumna:

		cmp ebx,edx 			;cmp el contador con el ancho-8
		jg ultimo

		jmp pepito			;me dejregistro lo que tengo que guardar, y en los siguientes 0
	sigoCol:		
		lea esi,[esi+6]
		lea edi,[edi+6]
		add ebx,6

		jmp cicloColumna


	ultimo:
		add esi,edx
		sub esi,ebx
		add edi,edx
		sub edi,ebx

		jmp pepito
	sigoFila:
		jmp pepito2
	sigoFila2:
		paddusb xmm6,xmm7
		movq [edi+eax+1],xmm6		

		sub esi, edx ;hacemos esi -( ancho - 8) 	
		add esi, eax ;esi = esi + paso

		sub edi, edx ;hacemos edi -( ancho - 8) 	
		add edi, eax ;edi = edi + paso
	
	loop cicloFila 

fin:

	convC_pop
	ret	







pepito:
		movq xmm0,[esi]
		movq xmm1,[esi+eax]
		movq xmm2,[esi+eax*2]

		punpcklbw xmm0,xmm3
		punpcklbw xmm1,xmm3
		punpcklbw xmm2,xmm3

		paddusw xmm0,xmm1
		
		paddusw xmm0,xmm2

		movdqu xmm1,xmm0
	
		psrldq xmm1,4
	
		psubusw xmm1,xmm0

		PACKUSWB xmm1,xmm1
		PSLLQ xmm1,16		
		PSRLQ xmm1,16
		;movq [edi+eax+1],xmm1
		movdqu xmm6,xmm1
		cmp ebx,edx
		jg sigoFila
		jmp sigoCol


pepito2:
		movq xmm0,[esi]
		movq xmm4,[esi+eax*2]

		punpcklbw xmm0,xmm3
		punpcklbw xmm4,xmm3

		movdqu xmm1,xmm0
		movdqu xmm2,xmm0

		psrldq xmm1,2
		psrldq xmm2,4
		
		paddusw xmm0,xmm1
		paddusw xmm0,xmm2
		

		movdqu xmm1,xmm4
		movdqu xmm2,xmm4

		psrldq xmm1,2
		psrldq xmm2,4

		paddusw xmm4,xmm1
		paddusw xmm4,xmm2

	
		psubusw xmm4,xmm0


		PACKUSWB xmm4,xmm4
		PSLLQ xmm4,16		
		PSRLQ xmm4,16
		;movq [edi+eax+1],xmm1
		movdqu xmm7,xmm4
		cmp ebx,edx
		jg sigoFila2
		jmp sigoCol


