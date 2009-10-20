; Macro para salvar los registros de la Convención C
%imacro convC_push 0
	enter 0,0
	push esi
	push edi
	push ebx
	push ecx
	push edx
%endmacro

; Macro para restaurar los registros de la Convención C
%imacro convC_pop 0
	pop edx
	pop ecx
	pop ebx
	pop edi
	pop esi
	leave
%endmacro 

