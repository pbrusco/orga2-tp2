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

	mov esi, src				;MUEVO A ESI EL PUNTERO AL SRC
	mov edi, dst				;MUEVO A EDI EL PUNTERO AL DESTINO
	mov ecx, alto				;MUEVO A ECX EL ALTO
	sub ecx, 2				;DECREMENTO ECX PARA QUE EL LOOP SE HAGA HASTA DOS LINEA MENOS QUE EL ALTO
	mov eax, paso				;MUEVO A EAX EL WSTEP O PASO
	mov edx, ancho				;MUEVO A EDX EL ANCHO
	sub edx,8				;RESTO A EDX (QUE CONTIENE EL ANCHO) 8, PARA EL RECORRIDO POR FILA
	pxor xmm3,xmm3				;DEJO 0  XMM3 



cicloFila:
	xor ebx,ebx				;LIMPIO EL CONTADOR DE PIXELES PROCESADOS
		
	cicloColumna:

		cmp ebx,edx 			;ME FIJO SI EL CONTADOR DE PIXELES PROCESADOS SUPERA AL ANCHO-8
		jg procesarUltimo		;EN CASO DE QUE SUCEDA PROCESO LA ULTIMA PARTE DE LA FILA

		jmp procesarYguardar
	sigoCol:
		
		add esi,6			;LUEGO DE PROCESAR (Y GUARDAR) POSICIONO LOS PUNTEROS DONDE CORRESPONDE
		add edi,6			;CORRIENDOME 6 LUGARES MAS ADELANTE
		add ebx,6			;SUMO AL CONTADOR DE PIXELES PROCESADOS LOS 6.

		jmp cicloColumna		;SIGO CON LA PROXIMA COLUMNA (O BLOQUE)


procesarUltimo:
		add esi,edx			;ACOMODO LOS INIDICES PARA PROCESAR LOS ULTIMOS 8 PIXELES
		sub esi,ebx
		add edi,edx
		sub edi,ebx

		JMP procesarYguardar

	sigoFila:

		add esi, eax 		
		sub esi, edx 			;COMO TERMINE LA FILA ACOMODO LOS INDICES PARA LA PROXIMA FILA
		add edi, eax 
		sub edi, edx 	
	
	loop cicloFila 				;VOY A LA SIGUIENTE FILA SI NO LLEGUE A COMPLETAR EL ALTO-1

fin:

	convC_pop
	ret	







procesarYguardar:
		movq xmm0,[esi]						;MUEVO A XMM0 LOS PRIMEROS 8 PIXELES (A)
		movq xmm1,[esi+eax]					;MUEVO B XMM1 LOS PRIMEROS 8 PIXELES DE LA FILA SIGUIENTE (B)
		movq xmm2,[esi+eax*2]					;MUEVO C XMM2 LOS PRIMEROS 8 PIXELES DE LA 3ER FILA (C)

		punpcklbw xmm0,xmm3					;DESEMPAQUETO LOS 3 VALORES
		punpcklbw xmm1,xmm3
		punpcklbw xmm2,xmm3

		paddusw xmm0,xmm1					;SUMO A CON B
			
		paddusw xmm0,xmm2					;SUMO A+B CON C

		movdqu xmm1,xmm0					;COPIO A+B+C EN XMM1
	
		psrldq xmm1,4						;SHIFTEO DOS PIXELES (EXPANDIDOS POR ESO 4 BYTES)
	
		psubusw xmm1,xmm0					;LE RESTO A+B+C a >>>>(A+B+C)  

		PACKUSWB xmm1,xmm1					;EMPAQUETO
		PSLLQ xmm1,16						;LIMPIO BASURAS
		PSRLQ xmm1,16
		movdqu xmm6,xmm1					;GUARDO EN XMM6 EL RESULTADO DE LA OPERACION (X)



		movq xmm0,[esi]						;MUEVO A XMM0 LOS PRIMEROS 8 PIXELES (A)
		movq xmm4,[esi+eax*2]				 	;MUEVO A XMM4 LOS PRIMEROS 8 PIXELES DE DOS FILAS MAS ABAJO (B)

		punpcklbw xmm0,xmm3					;DESEMPAQUETO A
		punpcklbw xmm4,xmm3					;DESEMPAQUETO B

		movdqu xmm1,xmm0					;COPIO A EN XMM1 (A')	
		movdqu xmm2,xmm0					;COPIO A EN XMM2 (A'')

		psrldq xmm1,2						;SHIFTEO A DERECHA 1 PIXEL (expandido,es decir 2 bytes) a A'
		psrldq xmm2,4						;SHIFTEO A DERECHA 2 PIXELES (expandidos,es decir 4 bytes) a A''
		
		paddusw xmm0,xmm1					;SUMO A MAS A' SHIFTEADA (A + >>A')
		paddusw xmm0,xmm2					;SUMO A MAS A'' SHIFTEADA 2 VECES (A + >>>>A'')
									;XMM0 = A + >>A' + >>>>A''

		movdqu xmm1,xmm4					;COPIO B EN XMM1 (B')
		movdqu xmm2,xmm4					;COPIO B EN XMM2 (B'')

		psrldq xmm1,2						;REPITO EL MISMO PROCESO QUE CON A, A' Y A''
		psrldq xmm2,4

		paddusw xmm4,xmm1
		paddusw xmm4,xmm2					;XMM4 = B + >>B' + >>>>B'' 

	
		psubusw xmm4,xmm0					;RESTO XMM4 - XMM0 


		PACKUSWB xmm4,xmm4					;EMPAQUETO XMM4
		PSLLQ xmm4,16						;SHIFTEO PARA ELIMINAR BASURAS
		PSRLQ xmm4,16
		movdqu xmm7,xmm4	
									;DEJO EL VALOR DE LA OPERACION (Y) EN XMM7 
		paddusb xmm6,xmm7
		movq [edi+eax+1],xmm6					;GUARDO EL RESULTADO (X+Y)

		cmp ebx,edx						;ME FIJO SI TERMINE O NO LA FILA.
		jg sigoFila
		jmp sigoCol

		
