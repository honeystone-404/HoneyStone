[org 0x7c00]
start:
	cli
	mov ax, 0x0000
	mov ds, ax

	mov bx, 0x8000
	mov ah, 0x02
	mov al, 1
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0x80
	int 0x13
	jc disk_error
	
	jmp 0x0000:0x8000
disk_error:
	hlt
	jmp disk_error
times 510-($-$$) db 0
dw 0xaa55

