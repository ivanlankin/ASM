include console.inc
extrn ExitProcess :proc,	;Импортируем все необходимые функции
	  GetLocalTime :proc,
	  wsprintfA :proc


SYSTEMTIME struct
    wYear word ?
    wMonth word ?
    wDayOfWeek word ?
    wDay word ?
    wHour word ?
    wMinute word ?
    wSecond word ?
    wMilliseconds word ?
SYSTEMTIME ends


.data
strWinAPItime db 'The WinAPI time is: %02i:%02i:%02i', 0Ah, 0
strWinAPIdate db 'The WinAPI date is: %02i.%02i.%04i', 0Ah, 0


.code
Start proc
	local systime         :SYSTEMTIME,
		  outputData[256] :byte
	STACKALLOC 1
	call InitConsole
	lea RCX, systime
	call GetLocalTime
	;call wsprintfA
	lea RCX, outputData
	lea RDX, strWinAPItime
	movzx R8, systime.wHour
	movzx R9, systime.wMinute
	movzx RAX, systime.wSecond
	mov qword ptr[RSP+32], RAX
	;push RAX
	call wsprintfA
	lea RAX, outputData
	push RAX
	call PrintString

	lea RCX, outputData
	lea RDX, strWinAPIdate
	movzx R8, systime.wDay
	movzx R9, systime.wMonth
	movzx RAX, systime.wYear
	mov qword ptr[RSP+32], RAX
	;push RAX
	call wsprintfA
	lea RAX, outputData
	push RAX
	call PrintString

	call WaitEnter
	xor RCX, RCX
	call ExitProcess

Start endp
end