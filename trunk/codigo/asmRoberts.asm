%include "macros.asm"
%define src [ebp +8]
%define dst [ebp +12]
%define ancho [ebp +16]
%define alto [ebp +20]
%define wstep [ebp +24]

;void asmRoberts(const char* src, char* dst, int ancho, int alto, int wstep)

global asmRoberts

section .data


section .text

asmRoberts:
	convC_push 

	mov esi,src				;MUEVO A ESI EL PUNTERO AL SRC
	mov edi,dst				;MUEVO A EDI EL PUNTERO AL DESTINO
	mov ecx,alto				;MUEVO A ECX EL ALTO
	mov eax,wstep				;MUEVO A EAX EL WSTEP O PASO
	mov edx,ancho				;MUEVO A EDX EL ANCHO

	dec ecx					;DECREMENTO ECX PARA QUE EL LOOP SE HAGA HASTA UNA LINEA MENOS QUE EL ALTO
	sub edx,16				;RESTO A EDX (QUE CONTIENE EL ANCHO) 16, PARA EL RECORRIDO POR FILA

cicloFila:
	
	xor ebx,ebx				;LIMPIO EL CONTADOR DE PIXELES PROCESADOS
	
	cicloColumna:				
		
		cmp ebx,edx			;ME FIJO SI EL CONTADOR DE PIXELES PROCESADOS SUPERA AL ANCHO-16
		jg procesarUltimo		;EN CASO DE QUE SUCEDA PROCESO LA ULTIMA PARTE DE LA FILA
		jmp proceso			;SINO PROCESO CON LOS PROXIMOS 16 PIXELES
	
	continuarConLaFila:
		add esi,15			;LUEGO DE PROCESAR (Y GUARDAR) POSICIONO LOS PUNTEROS DONDE CORRESPONDE
		add edi,15			;CORRIENDOME 15 LUGARES MAS ADELANTE
		add ebx,15			;SUMO AL CONTADOR DE PIXELES PROCESADOS LOS 15.
		jmp cicloColumna		;SIGO CON LA PROXIMA COLUMNA (O BLOQUE)

proceso:
	movdqu xmm0,[esi]			;OBTENGO 16 VALORES (A)
	movdqu xmm1,[esi+eax]		;OBTENGO LOS 16 DE ABAJO (B)
	movdqu xmm2,xmm0			;COPIO A (A')
	movdqu xmm3,xmm1			;COPIO B (B')
	psrldq xmm3,1				;SHIFTEO LA COPIA DE B A DERECHA 1 BYTE (>>B')
	psubusb xmm2,xmm3			;HAGO A MENOS LA COPIA DE B SHIFTEADA (A - >>B') (RES1)
	psrldq xmm0,1				;SHIFTEO A A DERECHA 1 BYTE (>>A)
	psubusb xmm0,xmm1			;HAGO EL SHIFTEO DE A MENOS B (>>A  - B) (RES2)
	paddusb xmm0,xmm2			;SUMO RES1 Y RES2
	pslldq xmm0,1				;LIMPIO EL ULTIMO BYTE CON 2 SHIFTS (UNO A IZQ Y UNO A DER)
	psrldq xmm0,1	
	movdqu [edi],xmm0			;GUARDO EN LA DIRECCION APUNTADA POR EDI
	cmp ebx,edx				;COMPARO EL CONTADOR DE PIXELES PROCESADOS PARA VER A DONDE RETORNO
	jle continuarConLaFila			;VUELVO CON LA FILA SI NO HABIA TERMINADO
	
	
	sub esi,edx				;COMO TERMINE LA FILA ACOMODO LOS INDICES PARA LA PROXIMA FILA
	add esi,eax	
	sub edi,edx
	add edi,eax
	
	loop cicloFila				;VOY A LA SIGUIENTE FILA SI NO LLEGUE A COMPLETAR EL ALTO-1
	jmp fin					;SINO FIN



procesarUltimo:			
	add esi,edx				;ACOMODO LOS INIDICES PARA PROCESAR LOS ULTIMOS 16 PIXELES
	sub esi,ebx
	add edi,edx
	sub edi,ebx	
	jmp proceso				;EJECUTO EL PROCESO DE CALCULO



fin:
	convC_pop				;CONVENCION C				
	ret									






