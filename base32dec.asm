;  Executable name : base32dec
;  Version         : 1.2
;  Created date    : 5.9.2018
;  Last update     : 12.12.2018
;  Author          : Sven De Gasparo
;  Description     : 
	
SECTION .data			; Section containing initialised data

	BASE32:	db "/usr/bin/base32",0
	BASE32_ARG: db "base32",0
	DECODE_ARG: db "--decode",0
	ARGV: dq BASE32_ARG, DECODE_ARG, 0
	
	
SECTION .bss			; Section containing uninitialized data



SECTION .text			; Section containing code

global 	_start			; Linker needs this to find the entry point!
	
_start:
	nop			; Keine Anweisung


write:
	mov rax, 59		; Code fuer sys-execenv
	mov rdi, BASE32		; stdout fd
	mov rsi, ARGV		; Ausgabe Adresse
	mov rdx, 0		; Ausgabegrösse
	syscall			; Kernel aufruf
	

done:	
	mov rax, 60		; Code um das Programm zu beenden
	mov rdi, 0		; Beenden mit 0 Code
	syscall			; Kernerl aufruf




