.model small                 ;Модель памяти SMALL использует сегменты 
                             ;размером не более 64Кб
.stack 100h                  ;Сегмент стека размером 100h (256 байт)
.data                        ;Начало сегмента данных
UserName db 'Lankin Ivan 251', 0Dh, 0Ah, '$'
.code                        ;Начало сегмента кода
start:                       ;Точка входа в программу start 
                             ;Предопределенная метка @data обозначает
                             ;адрес сегмента данных в момент запуска программы,
mov AX, @data                ;который сначала загрузим в AX,
mov DS,AX                    ;а затем перенесем из AX в DS
mov DX,offset UserName
mov AX, 04h
mov BX, 08h
call Out_string
call print_two_digits

mov AX,4C00h
int 21h

print_two_digits proc
		mov BL, AL
		call print_char
		mov BL, 20h
		mov AH, 02h
		mov DL, BL
		int 21h
		mov BL, AL
		call print_char
		ret
print_two_digits endp

print_char proc
		add BL, 30h
		mov AH, 02h
		mov DL, BL
		int 21h
		ret
print_char endp

Out_string proc
		mov AH,09h
		int 21h
		ret
Out_string endp



end start