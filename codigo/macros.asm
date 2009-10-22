; Macro para salvar los registros de la Convención C
%imacro convC_push 0-1 0
	push ebp
	mov ebp, esp
	sub esp, %1
	push esi
	push edi
	push ebx
	push ecx
	push edx
%endmacro

; Macro para restaurar los registros de la Convención C
%imacro convC_pop 0-1 0
	pop edx
	pop ecx
	pop ebx
	pop edi
	pop esi
	add esp, %1
	pop ebp
%endmacro 

