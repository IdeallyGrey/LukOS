    BITS 16

; Data

;    text_string db 'Hello world!', 0




; Main code

start:
    ORG 0x7C00 ; Set initial offset to where BIOS puts us

    mov ax, 07C0h ; Set stack segment
    add ax, 288
    mov ss, ax
    mov sp, 4096 ; Set stack pointer


	call vga_clear	; Clears screen






    mov si, welcome_string  ; Put string position into SI
	call vga_print_string; Call our string-printing routine





	jmp $			; Jump here - infinite loop!



vga_clear:
    mov dx, 0xb800 ; VGA buffer
    mov es, dx ; Extra Segment, has to be loaded from register

    mov cx, 0
.vga_clear_start:
    cmp cx, 4000 ; 80*25*2
    je .vga_clear_end
	mov di, cx
    mov byte [es:di], 0
    inc cx
    mov di, cx
    mov byte [es:di], 0 ; ()()(text)(back)
    inc cx
    jmp .vga_clear_start
.vga_clear_end:
    ret



vga_print_byte: ; Print contents of SI to screen via VGA buffer
    push dx
    push es
    push di
    push cx
    push ax

    mov dx, 0xb800 ; VGA buffer
    mov es, dx ; Extra Segment, has to be loaded from register
.vga_print_byte_start:
    mov ax, si

    push ax
    mov cx, 0
.vga_print_byte_find_end:
    mov di, cx
    mov ax, [es:di]
    cmp ax, 0
    je .vga_print_byte_find_end_done
    inc cx
    jmp .vga_print_byte_find_end

.vga_print_byte_find_end_done:
    pop ax

    mov di, cx
    mov byte [es:di], al
    inc cx
    mov di, cx
    mov byte [es:di], 0x1f

    pop ax
    pop cx
    pop di
    pop es
    pop dx
    ret



vga_print_string: ; Print contents of SI to screen via VGA buffer
    push cx
    push ax

.vga_print_string_start:
    lodsb ; Loads a single byte from SI to AL
    cmp al, 0 ; If 0, stop
    je .vga_print_string_done

    push si
    mov si, ax
    call vga_print_byte
    pop si

    jmp .vga_print_string_start

.vga_print_string_done:
    pop ax
    pop cx
    ret


    welcome_string dw "Welcome to LukBoot! We're in Real Mode right now.", 0




	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
