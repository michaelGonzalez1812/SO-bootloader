org         0x7c00
bits 16

boot:
    jmp main
    TIMES 3-($-$$) DB 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.

    ; Dos 4.0 EBPB 1.44MB floppy
    OEMname:           db    "mkfs.fat"  ; mkfs.fat is what OEMname mkdosfs uses
    bytesPerSector:    dw    512
    sectPerCluster:    db    1
    reservedSectors:   dw    1
    numFAT:            db    2
    numRootDirEntries: dw    224
    numSectors:        dw    2880
    mediaType:         db    0xf0
    numFATsectors:     dw    9
    sectorsPerTrack:   dw    18
    numHeads:          dw    2
    numHiddenSectors:  dd    0
    numSectorsHuge:    dd    0
    driveNum:          db    0
    reserved:          db    0
    signature:         db    0x29
    volumeID:          dd    0x2d7e5a1a
    volumeLabel:       db    "NO NAME    "
    fileSysType:       db    "FAT12   "

main:
	mov si, presmsg
	call _print
    call _wait

    mov ah, 0x02          ; ah = 2: read from drive
    mov cl, 0x02          ; sector         = 2
    mov al, 8 		   ; al = amount of sectors to read
    mov ch, 0          ; cylinder/track = 0
    mov dh, 0          ; head           = 0
    xor bx, bx
    mov es, bx
    mov bx, 0x8000     ; bx = address to write the kernel to    
    
    int 0x13   		   ; => ah = status, al = amount read
    jmp 0x0000:0x8000

;Prints null-terminated string
;Input  : SI - pointer to string
;Output :
_print:
	push ax
	push bx
	mov ah, 0xe
	mov bh, 0
	mov bl, 0x7
.loop:
	lodsb ;loads the character in to al from si reg
	cmp al, 0
	je .exit
	int 0x10
	jmp .loop	
.exit:
	pop bx
	pop ax
	ret

;Waits for key press
;Input  :
;Output :
_wait:
	push ax

	mov ah, 0x00
	int 0x16

	pop ax
	ret
	

presmsg db "Press any key to continue...  ",0

times 510-($-$$) db 0
;Begin MBR Signature
db 0x55 ;byte 511 = 0x55
db 0xAA ;byte 512 = 0xAA