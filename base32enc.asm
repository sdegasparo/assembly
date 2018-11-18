;  Executable name : base32enc
;  Version         : 1.0
;  Created date    : 5.9.2018
;  Last update     : 14.11.2018
;  Author          : Sven De Gasparo
;  Description     : 
	
SECTION .data			; Section containing initialised data

	Base32:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
	
	
SECTION .bss			; Section containing uninitialized data

	input resb 64		; 
	inputLength: equ 64	; 
	output: resb 512	;
	

SECTION .text			; Section containing code

global 	_start			; Linker needs this to find the entry point!
	
_start:

	
	nop			; Keine Instruktion
	



	
prepareInput:			; Alle Register welche ich benötige auf 0 setzen
	xor rax, rax		; Eingabe groesse speichern
	xor r10, r10		; Ausgabe groesse speichern


	
read:	
	mov rax, 0		; Gibt dem System Bescheid, dass wir lesen möchten
	mov rdi, 0		; Fangt beim Index 0 an
	mov rsi, input		; Es wird nach eingabe  geschrieben
	mov rdx, inputLength	; Die BuffLen länge
	add rsi, r10		; Den Pointer auf die letzte Zeilen zeigen
	syscall			; Ruft den CPU auf um den Buffer zu fuellen
	sub rsi, r10		; Den Pointer zurueck zum Anfang zeigen

T:				; Debug
	
checkDone:	
	cmp rax, 0		; Wenn rax=0 ist entspricht ctrl + D
	je done			; Springe zu Fertig, eax 0 ist.

;;; checkShouldReadAnotherLine???
	add rax, r10		; Input groesse zu rax addieren
	mov r10, rax		; rax in r10 speichern, damit mit rax gerechnet werden kann
	cmp byte [rsi+rax-1], 10 ; Vergleiche letzten Charakter mit neuer Zeile
	jne prepareRegister	 ; Wenn der letzte Charakter vom Input kiene neue Zeile ist dann encoden

	dec r10			; Ueberschreibe die neue Zeile
	jmp read		; Lese die naechste Zeile

prepareRegister:	
	xor rax, rax		; rax
	xor rbx, rbx		; rbx
	xor rcx, rcx		; rcx
	xor rdx, rdx		; rdx
	xor r8, r8		; r8 zaehler fuer durchlauf
	xor r9, r9		; r9

	
;;; Verarbeiten
shift:	
	;; 1. 5 bit
	mov bx, [rsi]		; Byte 1 + 2 in bx kopieren
	shr bx, 3		; 3 nach rechts shiften, damit die ersten 5 Bits verarbeitet werden. 1. Zeichen gefunden.
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben
	
	
	;; 2. 5 bit
	shl bx, 8		;
	shr bx, 3		; 2. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	;; Byte 2 + 3 einlesen
	mov bx, [rsi]		; Byte 2 + 3 in bx kopieren

	;; 3. 5 bit
	shl bx, 2
	shr bx, 3		; 3. Zeichen gefunden
	mov bh, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	;; 4. 5 bit
	shl bx, 8
	shr bx, 3		; 4. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	;; Byte 3 + 4 einlesen
	mov bx, [rsi]		; Byte 3 + 4 einlesen

	;; 5. 5 bit
	shl bx, 4
	shr bx, 3		; 5. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	;; 6. 5 bit
	shl bx, 8
	shr bx, 3		; 6. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	;; Byte 4 + 5 einlesen
	mov bx, [rsi]		; Byte 4 + 5 einlesen

	;; 7. 5 bit
	shl bx, 6
	shr bx, 3		; 7. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	;; 8. 5 bit
	shl bx, 8
	shr bx, 3		; 8. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutput		; Base32 Charakter ausgeben

	
	cmp rsi, 0		; Vergleicht ob noch Daten vorhanden sind.
	jnz shift 		; Wenn noch Daten vorhanden sind springe zu Shift und beginne das Prozedere von vorne
	

write:
	mov rax, 1		; Code um zu schreiben (sys-write)
	mov rdi, 1		; stdout fd
	mov rsi, output		; Ausgabe Adresse
	mov rdx, r8		; Ausgabegrösse
	syscall			; Kernel aufruf
	

done:	
	mov rax, 60		; Code um das Programm zu beenden
	mov rdi, 0		; Beenden mit 0 Code
	syscall			; Kernerl aufruf

; METHODEN

addOutput:
	mov [output+r9], cl 	; Ausgabe des Base32 Zeichen
	inc rsi			; rsi um 1 erhöhen für das nächste Byte
	dec r10
	cmp r10, 0 		; Vergleicht ob noch Daten vorhanden sind.
	jz write		; Wenn keine Daten mehr vorhanden sind Springe zu Schreiben
	ret			; Zurück zum Code


	

	




