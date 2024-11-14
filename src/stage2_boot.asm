[org 0x8000]               ; Origin for second stage at 0x8000
start:
    cli                    ; Disable interrupts during setup
    lgdt [gdt_descriptor]  ; Load GDT

    ; Enable Protected Mode
    mov eax, cr0
    or eax, 1              ; Set the PE bit
    mov cr0, eax

    ; Far jump to clear the pipeline and switch to protected mode
    jmp 0x08:protected_mode_entry

; Define a simple Global Descriptor Table (GDT)
gdt:
    ; NULL descriptor (required)
    dw 0x0000
    dw 0x0000
    db 0x00
    db 0x00
    db 0x00
    db 0x00

    ; Code Segment descriptor
    dw 0xFFFF              ; Segment limit (low 16 bits)
    dw 0x0000              ; Base address (low 16 bits)
    db 0x00                ; Base address (middle 8 bits)
    db 0x9A                ; Access byte: 1 0 0 1 1 0 1 0 (code segment, readable, executable)
    db 0xCF                ; Flags: Limit (high 4 bits), AVL=0, L=0, D=1 (32-bit), G=1
    db 0x00                ; Base address (high 8 bits)

    ; Data Segment descriptor
    dw 0xFFFF              ; Segment limit (low 16 bits)
    dw 0x0000              ; Base address (low 16 bits)
    db 0x00                ; Base address (middle 8 bits)
    db 0x92                ; Access byte: 1 0 0 1 0 0 1 0 (data segment, writable)
    db 0xCF                ; Flags: Limit (high 4 bits), AVL=0, L=0, D=1 (32-bit), G=1
    db 0x00                ; Base address (high 8 bits)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt - 1   ; GDT size (limit)
    dd gdt                 ; GDT base address

; Code execution continues here after entering protected mode
[bits 32]                  ; Switch to 32-bit mode for protected mode
protected_mode_entry:    
    ; Set up segment registers to point to the data segment
    mov ax, 0x10           ; Data segment selector in GDT (0x10 for data segment)
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9FC00       ; Set stack pointer (within available memory)

    ; Now in protected mode, proceed with loading the OS or kernel
    ; Display "Hello, World!" message on the screen
    mov esi, msg           ; Load address of message
    call print_string      ; Print string only once

halt:
    hlt                    ; Halt the CPU (for testing)
    jmp halt               ; Infinite loop to keep CPU in halt state

vga_buffer equ 0xB8000     ; VGA text mode buffer address
text_color equ 0x07        ; Light gray on black background

; Routine to print a null-terminated string to the screen
print_string:
    mov edi, vga_buffer    ; Set EDI to start of VGA buffer
.loop:
    lodsb                  ; Load byte from [ESI] (the message)
    or al, al              ; Check if it's null (end of string)
    jz .end                ; If null, exit loop
    mov ah, text_color     ; Set color attribute in high byte
    stosw                  ; Write character and color to VGA buffer
    jmp .loop              ; Repeat for next character
.end:
    ret

msg db "Hello, World!", 0   ; Null-terminated message
