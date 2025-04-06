    BITS 16

    jmp start

; ---- Data ----

    welcome_string: dw "Welcome to LukOS! Here are the numbers in the fibonacci sequence under 1 billion:", 0
    space: db " ", 0


gdt: ; Global Description Table - each entry 8 bytes, our two segments define the same area
gdt_null EQU $-gdt ; first entry has to be null
    dq 0
gdt_code EQU $-gdt ; Code
    dw 0FFFFh ; Sets limit to 4G (max possible)
    dw 0 ; Where it starts

    db 0 ; Continuation of start
    db 10011010b ; Type
    db 11001111b
    db 0
gdt_data EQU $-gdt ; Data and stack
    dw 0FFFFh
    dw 0

    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:

gdt_desc: ; Used by NASM to find address
gdt_size   dw gdt_end-gdt-1
gdt_base   dd gdt


; ---- Bootloader ----

start:
    ORG 0x7C00 ; Set initial offset to where BIOS puts us

; Needed if we want to do stuff before entering protected mode, otherwise not nessesary
;    mov ax, 07C0h ; Set stack segment
;    add ax, 288
;    mov ss, ax
;    mov sp, 4096 ; Set stack pointer

; Preparing to enter Protected mode ------
	cli ; disables interupts

	xor ax, ax
	mov ds, ax ; sets ds to null (ds can't be set directly)

	lgdt [gdt_desc] ; loads GDT table

; Here we enter Protected mode -----
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


    call vga_clear

    mov esi, welcome_string
    call vga_print_string






    mov ecx, 0 ; prev
    mov eax, 1 ; current
loop:
    cmp ecx, 1000000000
    jg loop_end
    mov esi, space
    call vga_print_string
    mov esi, ecx
    call vga_print_integer
    mov edx, eax ; store current
    add eax, ecx ; add prev to current
    mov ecx, edx ; update prev to what was current
    jmp loop
loop_end:










hang:
	jmp hang	; infinite loop!




vga_print_integer: ; Recursive function to print the integer passed in ESI via the VGA buffer
    push eax
    push esi
    push edx
    push ecx

    mov eax, esi ; Set dividend
    mov ecx, 10       ; set to divide by 10
    mov edx, 0        ; clear dividend
    div ecx           ; EAX = 0x80, EDX = 0x3

    cmp eax, 0 ; If nothing left, skip
    je .vga_print_integer_done

    mov esi, eax ; otherwise, do remainder
    call vga_print_integer

.vga_print_integer_done:

    add edx, 0x30       ; adds 0x30 since the unicode for "0" is 0x30, unicode "1" is 0x31, unicode "2" is 0x32, etc..
    mov esi, edx
    call vga_print_byte

    pop ecx
    pop edx
    pop esi
    pop eax
    ret





vga_clear: ; Clears the screen
    push edi
    push ecx

    mov edi, 0xb8000 ; VGA buffer
    mov ecx, 0xb8000
    add ecx, 4000 ; 80*25*2 = End of VGA buffer
.vga_clear_start:
    cmp edi, ecx
    je .vga_clear_end ; Triggers when reaches end
    mov byte [edi], 0 ; Blank
    inc edi
    mov byte [edi], 0 ; Black background
    inc edi
    jmp .vga_clear_start
.vga_clear_end:

    pop ecx
    pop edi
    ret




vga_print_byte: ; Print byte in ESI to screen via VGA buffer
    push edi
    push ecx
    push eax

    mov edi, 0xb8000 ; VGA buffer
.vga_print_byte_find_end: ; Finds next blank space
    mov ecx, [edi]
    cmp ecx, 0
    je .vga_print_byte_find_end_done
    inc edi
    jmp .vga_print_byte_find_end

.vga_print_byte_find_end_done: ; Prints byte to that space
    mov eax, esi
    mov byte [edi], al
    inc edi
    mov byte [edi], 0x1f ; White on blue

    pop eax
    pop ecx
    pop edi
    ret




vga_print_string: ; Print string in ESI to screen via VGA buffer
    push eax

.vga_print_string_start:
    lodsb ; Loads a single byte from ESI to AL
    cmp al, 0 ; If 0, stop
    je .vga_print_string_done

    push esi
    mov esi, eax
    call vga_print_byte
    pop esi

    jmp .vga_print_string_start

.vga_print_string_done:

    pop eax
    ret










	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
