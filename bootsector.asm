    BITS 16

start:
    ORG 0x7C00 ; Set initial offset to where BIOS puts us

    mov ax, 07C0h ; Set stack segment
    add ax, 288
    mov ss, ax
    mov sp, 4096 ; Set stack pointer


	call vga_clear	; Clears screen
;
;    mov si, welcome_string  ; Put string position into SI
;	call vga_print_string;


; Prepare to enter Protected mode
	cli ; disables interupts

	xor ax, ax ; sets ax to null
	mov ds, ax ; sets ds to ax (can't be set directly)

	lgdt [gdt_desc] ; loads GDT table

; Here we enter Protected mode
	mov eax, cr0 ; Copies control register
    or eax, 1 ; Sets lowest bit to 1, (which enables Protected mode)
    mov cr0, eax ; Copies back

    jmp 08h:clear_pipe ; Does a "long jump" to clear old 16-bit instructions
[BITS 32]
clear_pipe:
    mov eax, gdt_data; Set stack segment
    mov ds,eax
    mov es,eax
    mov fs,eax
    mov gs,eax
    mov ss,eax
    mov esp, 0xffff ; Sets stack pointer




;    call vga_clear	; Clears screen


;    mov si, welcome_string  ; Put string position into SI
;    call vga_print_string;


hang:
	jmp hang	; Jump here - infinite loop!







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










; Data

    welcome_string dw "Welcome to LukBoot! We're in Real Mode right now.", 0

gdt: ; Global Description Table, for segmented memory
gdt_null EQU $-gdt
    dq 0 ; All 4 double words are null
gdt_code EQU $-gdt
    dw 0FFFFh ; Sets limit to 4G (max possible)
    dw 0 ; Where it starts

    db 0 ; Continuation of start
    db 10011010b ; Type
    db 11001111b
    db 0
gdt_data EQU $-gdt
    dw 0FFFFh
    dw 0

    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:

gdt_desc:
gdt_size   dw gdt_end-gdt-1
gdt_base   dd gdt



	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
