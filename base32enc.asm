;  Executable name : base32enc
;  Version         : 1.0
;  Created date    : 5.9.2018
;  Last update     : 26.11.2018
;  Author          : Sven De Gasparo
;  Description     : 
	
SECTION .data			; Section containing initialised data

	Base32:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
	
	
SECTION .bss			; Section containing uninitialized data

	input resb 4096		; Byte reservieren für den Input
	inputLength: equ 4096	; 
	output: resb 4096	; Byte reservieren für den Output
	

SECTION .text			; Section containing code

global 	_start			; Linker needs this to find the entry point!
	
_start:
	
	nop			; Keine Instruktion
	
	
prepareInput:			; Alle Register welche ich benötige auf 0 setzen
	xor r10, r10		; Eingabe groesse speichern counter



	
read:	
	mov rax, 0		; Gibt dem System Bescheid, dass wir lesen möchten
	mov rdi, 0		; Fangt beim Index 0 an
	mov rsi, input		; Es wird nach input geschrieben
	mov rdx, inputLength	; Die inputlänge
	add rsi, r10		; Den Pointer auf die letzte Zeilen zeigen
	syscall			; Ruft den CPU auf um den Buffer zu fuellen
	sub rsi, r10		; Den Pointer zurueck zum Anfang zeigen


	
checkDone:	
	cmp rax, 0		; Wenn rax=0 ist entspricht ctrl + D
	je done			; Springe zu Fertig, wenn rax 0 ist.

;;; checkShouldReadAnotherLine???
	add rax, r10		 ;Input groesse zu rax addieren
	mov r10, rax		; r10 als counter verwenden
	cmp byte [rsi+rax-1], 10 ; Vergleiche letzten Charakter mit neuer Zeile
	jne prepareRegister	 ; Wenn der letzte Charakter vom Input kiene neue Zeile ist dann encoden

	dec r10			; Ueberschreibe die neue Zeile
	jmp read		; Lese die naechste Zeile

prepareRegister:	
	xor rax, rax		; rax
	xor rbx, rbx		; rbx
	xor rcx, rcx		; rcx
	xor rdx, rdx		; rdx
	xor r8, r8		;
	xor r9, r9		; 
	xor r11, r11		; Ausgabe groesse counter speichern

T:				; Debug
	
;;; Verarbeiten
shift:	
	;; 1. 5 bit
	mov bx, [rsi]		; Byte 1 + 2 in bx kopieren
	shr bx, 3		; 3 nach rechts shiften, damit die ersten 5 Bits verarbeitet werden. 1. Zeichen gefunden.
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputFirst	; Base32 Charakter ausgeben
	
	
	;; 2. 5 bit
	shl bx, 8		;
	shr bx, 3		; 2. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputSecond	; Base32 Charakter ausgeben

	;; Byte 2 + 3 einlesen
	mov bx, [rsi]		; Byte 2 + 3 in bx kopieren

	;; 3. 5 bit
	shl bx, 2
	shr bx, 3		; 3. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputFirst	; Base32 Charakter ausgeben

	;; 4. 5 bit
	shl bx, 8
	shr bx, 3		; 4. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputSecond	; Base32 Charakter ausgeben

	;; Byte 3 + 4 einlesen
	mov bx, [rsi]		; Byte 3 + 4 einlesen

	;; 5. 5 bit
	shl bx, 4
	shr bx, 3		; 5. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputFirst	; Base32 Charakter ausgeben

	;; 6. 5 bit
	shl bx, 8
	shr bx, 3		; 6. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputSecond	; Base32 Charakter ausgeben

	;; Byte 4 + 5 einlesen
	mov bx, [rsi]		; Byte 4 + 5 einlesen

	;; 7. 5 bit
	shl bx, 6
	shr bx, 3		; 7. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputFirst	; Base32 Charakter ausgeben

	;; 8. 5 bit
	shl bx, 8
	shr bx, 3		; 8. Zeichen gefunden
	mov cl, [Base32+ebx]	; Verwandle Eingabe in Base32 Charakter um
	call addOutputSecond	; Base32 Charakter ausgeben

	
	cmp rsi, 0		; Vergleicht ob noch Daten vorhanden sind.
	jnz shift 		; Wenn noch Daten vorhanden sind springe zu Shift und beginne das Prozedere von vorne

	
addEqualSign:
	mov rax, r11		; Divident: Counter für Anzahl Bytes in Rax kopieren
	mov r13, 8		; Divisor: 8
	div r13			; rax durch r13 = 8 rechnen
	cmp rdx, 0		; Überprüfen ob die Division keinen Rest ergibt
	jz write		; Wenn 0 dann sind es alles Achterblöcke
	mov [output+r11], byte '=' ; EqualSign in die Ausgabe schreiben
	inc r11			   ; Counter für Output erhöhen
	jmp addEqualSign	   ; Wieder Überprüfen ob es ein EqualSign benötigt
	

write:
	mov rax, 1		; Code um zu schreiben (sys-write)
	mov rdi, 1		; stdout fd
	mov rsi, output		; Ausgabe Adresse
	mov rdx, r11		; Ausgabegrösse
	syscall			; Kernel aufruf
	

done:	
	mov rax, 60		; Code um das Programm zu beenden
	mov rdi, 0		; Beenden mit 0 Code
	syscall			; Kernerl aufruf

; METHODEN

addOutputFirst:			; Für den ersten Durchlauf nach dem einlesen des Bits
	mov [output+r11], cl 	; Ausgabe des Base32 Zeichen
	inc r11			; counter für die Länge heraufzählen
	ret			; Zurück zum Code

addOutputSecond:	       ; Für den zweiten Durchlaufen nach dem einlesen des Bits
	mov [output+r11], cl 	; Ausgabe des Base32 Zeichen
	inc r11			; counter für die Länge heraufzählen
	inc rsi			; rsi um 1 erhöhen für das nächste Byte
	dec r10			; counter r10 runterzählen
	cmp r10, 0 		; Vergleicht ob noch Daten vorhanden sind.
	jz addEqualSign		; Wenn keine Byte mehr vorhanden sind Springe zu addEqualSign
	ret			; Zurück zum Code

	

	




