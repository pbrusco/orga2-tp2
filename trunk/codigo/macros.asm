; Macro para salvar los registros de la Convención C
%imacro convC_push 1
	enter 0,0
	sub esp, %1
	push esi
	push edi
	push ebx
%endmacro

; Macro para restaurar los registros de la Convención C
%imacro convC_pop 1
	pop ebx
	pop edi
	pop esi
	add esp, %1
	leave
%endmacro 

