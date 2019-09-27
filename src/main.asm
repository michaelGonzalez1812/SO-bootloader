[ORG 0x8000]
[BITS 16]

_main:
	call _clear ; limpia la ppantalla

	mov si, menulvl ; crea el menu
	call _printmenu ; imprime el menu
;.loop1:
;	call _waitlvl
;	cmp ax, 1
;	je .loop1

	call _initpic
	call _initirq1

	call _waitlvl

_initgame:
	call _clear ; limpia la ppantalla
	call _initPRNG
	call _initmap	

	mov si, cmdmsg
	mov dh, 0x2
	mov dl, 0x0
	call _printstr

	mov si, applestr
	mov dh, 0x1
	mov dl, 24
	call _printstr

	mov si, levelstr
	mov dh, 43
	mov dl, 24
	call _printstr

	call _newapple
	call _newlemon
	call _neworange

.loop:
	call _stepPRNG
	call _mapupdate
	call _snakeupdate
	cmp ax, 1
	je _idle

	mov ax, 0x8
	call _sleep		
	jmp .loop	

_idle:
	jmp _idle

;Inits map
;Input  :
;Output :
_initmap:
	push ax
	push bx
	push cx
	push dx
	xor bx, bx
	xor dx, dx
.loop:
	call _cimborder
	mov [typemap+bx], al
	mov [lifemap+bx], byte 0xFF
		
	cmp al, 1
	je .wall
	jne .air
.wall:
	mov cx, borderchar
	call _pchar
	jmp .skip2
.air:
	mov cx, airchar
	call _pchar
	
.skip2:
	inc dh
	cmp dh, 80
	jne .skip
	inc dl
	xor dh, dh
.skip:	
	inc bx
	cmp bx, 2000
	jne .loop


	;update the apple count
	mov dl, 24
	mov dh, 50
	xor eax, eax
	mov al, byte [menukey]
	call _inttostr
	mov cx, di
	mov ch, 0x12
	call _pchar

	
	mov dl, 4
	mov dh, 4
	mov cl, 4
	mov ch, 1
;	call _makewall

	pop dx
	pop cx
	pop bx
	pop ax
	ret




;*****************************************
; description: modify the typemap matrix
; input:
;	dl -> x 4
;	dh -> y 4
;	cl -> lenght 4
;	ch -> horizontal? 1
; output:
;*****************************************
_makewall:
	push ax
	push bx
	push cx
	push dx

.loop1:
	xor ax, ax
	mov al, dl
	mov bx, 80
	mul bx
	add al, dh
	xor bx, bx
	mov bx, ax
	
	mov [typemap+bx], byte 0x1
;	push cx
	xor cx, cx
	mov cx, borderchar
	;mov dl, 4
	;mov dh, 4
	call _pchar
;	pop cx
	inc dl
	cmp dl, 10
	jne .loop1

	pop dx
	pop cx
	pop bx
	pop ax
	ret

;Updates map
;Input  :
;Output :
_mapupdate:
	push ax
	push bx
	push cx
	push dx

	xor bx, bx
	xor dx, dx

	mov cx, airchar
.loop:
	mov al,byte [lifemap+bx]
	cmp al, 0
	je .nolife
	cmp al, 0xff
	je .skip
	dec byte [lifemap+bx]	
	jmp .skip
.nolife:
	mov byte [typemap+bx], 0
	mov byte [lifemap+bx], 0xff
	call _pchar
.skip:
	inc dh
	cmp dh, 80
	jne .skip2
	inc dl
	xor dh, dh
.skip2:	
	inc bx
	cmp bx, 2000
	jne .loop	

	;update the apple count
	mov dl, 24
	mov dh, 9
	xor eax, eax
	mov al, byte [applecont]
	call _inttostr
	mov cx, di
	mov ch, 0x12
	call _pchar
	
	mov dl, 24
	mov dh, 10
	shr edi, 8
	mov cx, di
	mov ch, 0x12
	call _pchar

	pop dx
	pop cx
	pop bx
	pop ax
	ret


;Updates snake
;Input  :
;Output : ax - 1 on failure
_snakeupdate:
	push bx
	push cx
	push dx

	mov al, byte [direction]
	cmp al, 0
	je .up
	cmp al, 1
	je .right
	cmp al, 2
	je .down
	cmp al, 3
	je .left	

.up:
	dec byte [snakeYpos]
	jmp .skip
.down:
	inc byte [snakeYpos]
	jmp .skip
.right:
	inc byte [snakeXpos]
	jmp .skip
.left:
	dec byte [snakeXpos]
	jmp .skip

.skip:
	xor ax, ax
	xor bx, bx
	xor dx, dx
	mov al, [snakeYpos]
	mov bx, 80
	mul bx
	xor bx, bx
	mov bl, [snakeXpos]
	add ax, bx
	
	xor bx, bx
	mov bx, ax
	
	mov al, [typemap+bx]
	cmp al, 1
	je .failure
	cmp al, 2
	je .failure
	cmp al, 3
	jne .skip2
	
	inc byte [length]
	call _newapple ; llamada a crear la fruta nueva despues de comerla
	;aumentamos el contador de manzanas
	call _neworange ; llamada a crear la fruta nueva despues de comerla
	call _newlemon ; llamada a crear la fruta nueva despues de comerla
	inc byte [applecont]
.skip2:
	mov [typemap+bx], byte 0x2
	mov al, [length]
	mov [lifemap+bx], al 
	mov cx, snakechar
	mov dh, [snakeXpos]
	mov dl, [snakeYpos]
	call _pchar
	
	mov ax, 0
	pop dx
	pop cx
	pop bx

	ret	
.failure:
	mov ax, 1
	pop dx
	pop cx
	pop bx

	ret

;Creates new apple on the map
;Input  :
;Output :
_newapple:
	push ax
	push bx
	push cx
	push dx

	xor dx, dx
	mov ax, [currentPRN]
	mov bx, 78
	div bx
		
	mov cl, dl	
	inc cl
	
	call _stepPRNG

	xor dx, dx
	mov ax, [currentPRN]
	mov bx, 23	
	div bx
	
	mov ch, dl
	inc ch	

	mov dx, cx
	mov cx, applechar
	
	xor dh, dl
	xor dl, dh
	xor dh, dl

	push dx

	call _pchar

	pop dx	
	
	xor ax, ax
	mov al, dl
	mov bl, 80
	mul bl
		
	movzx dx, dh		

	add ax, dx

	mov bx, ax

	mov ax, 3
	mov [typemap+bx], ax
	
	pop dx
	pop cx
	pop bx
	pop ax

	ret

;Creates new lemon on the map
;Input  :
;Output :
_newlemon:
	push ax
	push bx
	push cx
	push dx

	xor dx, dx
	mov ax, [currentPRN]
	mov bx, 78
	div bx
		
	mov cl, dl	
	inc cl
	
	call _stepPRNG

	xor dx, dx
	mov ax, [currentPRN]
	mov bx, 23	
	div bx
	
	mov ch, dl
	inc ch	

	mov dx, cx
	mov cx, lemonchar
	
	xor dh, dl
	xor dl, dh
	xor dh, dl

	push dx

	call _pchar

	pop dx	
	
	xor ax, ax
	mov al, dl
	mov bl, 80
	mul bl
		
	movzx dx, dh		

	add ax, dx

	mov bx, ax

	mov ax, 3
	mov [typemap+bx], ax
	
	pop dx
	pop cx
	pop bx
	pop ax

	ret

;Creates new orange on the map
;Input  :
;Output :
_neworange:
	push ax
	push bx
	push cx
	push dx

	xor dx, dx
	mov ax, [currentPRN]
	mov bx, 78
	div bx
		
	mov cl, dl	
	inc cl
	
	call _stepPRNG

	xor dx, dx
	mov ax, [currentPRN]
	mov bx, 23	
	div bx
	
	mov ch, dl
	inc ch	

	mov dx, cx
	mov cx, orangechar
	
	xor dh, dl
	xor dl, dh
	xor dh, dl

	push dx

	call _pchar

	pop dx	
	
	xor ax, ax
	mov al, dl
	mov bl, 80
	mul bl
		
	movzx dx, dh		

	add ax, dx

	mov bx, ax

	mov ax, 3
	mov [typemap+bx], ax
	
	pop dx
	pop cx
	pop bx
	pop ax

	ret


;Checks if given index is index of map border
;Input  : bx - index
;Output : al - 1 if true, 0 if false
_cimborder:
	push ax
	push bx
	push dx

	cmp bx, 80
	jb .true
	cmp bx, 1920
	ja .true

	mov ax, bx
	xor dx, dx
	mov bx, 80
	div bx
	cmp dx, 0
	je .true
	cmp dx, 79
	je .true
	
.false:
	pop dx
	pop bx
	pop ax
	
	mov al, 0
	ret	
.true:
	pop dx
	pop bx
	pop ax
	
	mov al, 1
	ret

;Inits PRNG
;Input  :
;Output :
_initPRNG:
	push ax

	cli
	mov al, 0x00
	out 0x70, al
	times 20 nop
	in al, 0x71
	mov [currentPRN], al
	mov al, 0x02
	out 0x70, al
	times 20 nop
	in al, 0x71
	mov [currentPRN+1], al

	call _stepPRNG

	pop ax
	ret

;Steps PRNG
;Input  :
;Output :
_stepPRNG:
	push ax
	push bx
	push cx
	push dx

	mov ax, [currentPRN]
	
	mov bx, 6214
	mul bx
		
	add ax, 421

	xor dx, dx	
	mov bx, 16248
	div bx

	mov [currentPRN], dx

	pop dx
	pop cx
	pop bx
	pop ax
	ret

;Return after given time
;Input  : ax - time
;Output :
_sleep:
	cli
	push ax
	mov [sleepleft], ax
	xor ax, ax
.loop:
	mov ax, [sleepleft]
	cmp ax, 0
	je .exit
	sti
	times 30 nop
	jmp .loop
	
.exit:
	sti
	pop ax
	ret

;Inits PIC
;Input  :
;Output :
_initpic:
	push ax

	;set up IVT	
	cli
	mov ax, ds
	push ax	
	xor ax, ax
	mov ds, ax

	mov ax, cs

	mov [0x0022], ax

	mov ax, _handle0
	
	mov [0x0020], ax

	pop ax
	mov ds, ax
	;set up PIC
	mov al,00110110b
	out 0x43, al
	mov ax, 0x3e9c      
	out 0x40,al                     
	mov al,ah                     
	out 0x40,al 

	sti
	pop ax
	ret

;Set up IRQ1 
;Input  :
;Output :
_initirq1:
	push ax
	cli
	mov ax, ds
	push ax	
	xor ax, ax
	mov ds, ax

	mov ax, cs

	mov [0x0026], ax

	mov ax, _handle1
	
	mov [0x0024], ax

	pop ax
	mov ds, ax
	pop ax
	sti
	ret

;Handle IRQ1
;Input  :
;Output :
_handle1:
	push ax
	push bx
	in al, 0x60 ;key buffer
	
	mov bl, [direction]
	cmp al, 0x48
	mov [direction], byte 0
	je .exit
	cmp al, 0x50
	mov [direction], byte 2
	je .exit
	cmp al, 0x4d
	mov [direction], byte 1
	je .exit
	cmp al, 0x4b
	mov [direction], byte 3
	je .exit
	cmp al, 0xa6
	mov [direction], byte 4
	je .exit

	mov [direction], bl

	cmp al, 0x02
	mov [menukey], byte 0x1
	je .exit

	cmp al, 0x03
	mov [menukey], byte 0x2
	je .exit

	cmp al, 0x04
	mov [menukey], byte 0x3
	je .exit

	
.exit:
	mov al, 0x20
	out 0x20, al
	pop bx
	pop ax
	iret		

;Handle IRQ0
;Input  :
;Output :
_handle0:
	push ax
	mov ax, [sleepleft]
	cmp ax, 0
	je .exit
	dec word [sleepleft]
.exit:
	mov al, 0x20
	out 0x20, al  
	pop ax
	iret	

;Clears screen
;Input  : CH - background color << 4 
;Output :
_clear:
	push AX
	push CX
	push DX

	;DL - row number
	;DH - column number
	xor DL, DL
.clearRow:
	xor DH, DH
.rowloop:
	mov CL, 0x20
	call _pchar
	inc DH
	cmp DH, 80
	jne .rowloop		
	inc DL
	cmp DL, 25
	jne .clearRow	

.exit:	
	pop CX
	pop DX
	pop AX
	ret

;input:
;	EAX: number
;output:
;	EDI: ascii array
_inttostr:
	push ax
	push bx
	push cx
	push dx

    mov ebx, 0xCCCCCCCD             
    xor edi, edi
.loop:
    mov ecx, eax                    ; save original number

    mul ebx                         ; divide by 10 using agner fog's 'magic number'
    shr edx, 3                      ;

    mov eax, edx                    ; store it back into eax

    lea edx, [edx*4 + edx]          ; multiply by 10
    lea edx, [edx*2 - '0']          ; and ascii it
    sub ecx, edx                    ; subtract from original number to get remainder

    shl edi, 8                      ; shift in to least significant byte
    or edi, ecx                     ;

    test eax, eax
    jnz .loop 

	pop dx
	pop cx
	pop bx
	pop ax
	ret

;Prints char to given x,y with given attribs
;Input  : CH - background color, text color
;	  CL - ASCII char
;	  DH - y pos
;	  DL - x pos
;Output :	
_pchar:
	push AX
	push BX

	mov BX, DS
	push BX
	mov BX, videomemseg
	mov DS, BX

	mov AX, 2
	mul DH
	mov BX, AX
	mov AX, 160
	mul DL
	add BX, AX

	mov [BX], CX	

	pop BX
	mov DS, BX

	pop BX
	pop AX
	ret
	
;Prints commands to play
;Input: 
;	- SI - pointer to string
;	- dh - y initial pos
;	- dl - x initial pos
_printstr:
	push ax
	push bx
	push cx
	push dx

.loop:
	lodsb
	cmp al, 0
	je .exit
	mov cl, al
	mov ch, 0x12
	call _pchar
	inc dh
	jmp .loop

.exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret

;Prints menu to select difficulty
;Input  : SI - pointer to string
_printmenu:
	push ax
	push bx
	push cx
	push dx

	xor dl, 10
	xor dh, 20

.loop:
	lodsb
	cmp al, 0
	je .exit
	mov cl, al
	mov ch, 0x12
	call _pchar
	inc dh
	jmp .loop

.exit:
	pop dx
	pop cx
	pop bx
	pop ax

	ret

; Waits until press a key for level
_waitlvl:
	push ax
	push bx
	
	mov [menukey], byte 0x00

.loop:
	mov al, byte[menukey]
	cmp al, 0x00
	je .loop

	cmp al, 0x1
	je .level1

	cmp al, 0x2
	je .level2

	cmp al, 0x3
	je .level3

.level1:
	jmp _initgame
.level2:
	jmp _initgame
.level3:
	jmp _initgame

	pop bx
	pop ax
	ret

;------------------------------
cmdmsg db "arrows: up, down, left, right || l = pause || space = reverse",0
menulvl db "Easy: [1] || Medium: [2] || Hard: [3]",0
applestr db "apples: ", 0
levelstr db "level: ", 0



sleepleft dw 0

currentPRN dw 0

direction db 0
length db 2

menukey db 0

snakeXpos db 70
snakeYpos db 20

;lleva la cuenta de manzanas
applecont db 0

videomemseg equ 0xB800

airchar    equ 0x0000
borderchar equ 0x30B0
snakechar  equ 0x5020
applechar  equ 0x4023
lemonchar  equ 0x2023
orangechar  equ 0x6023

times 4096-($-$$) db 0

section .bss

typemap resb 2000
lifemap resb 2000

