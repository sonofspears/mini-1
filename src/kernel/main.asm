
org 0x0000
bits 16
%define CR 0x0d
%define LF 0x0a

section .text

start:
main:

    ; setup stack
;    mov ss, cs
;    mov sp, $kernel_stack

    ; print message
    mov si, msg_hello
    call puts

    jmp wait_key_and_reboot

.halt:
    cli 
    hlt
    jmp .halt

; Print a null terminated string to the screen.
; Params:
;   - ds:si points to string
puts:
    ; save registers
    push si
    push ax

.loop:
    lodsb           ; load next character in al
    or al, al       ; verify if next character is null
    jz .done

    mov ah, 0x0e    ; call bios interrupt
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret    

wait_key_and_reboot:

    mov si, msg_any_key
    call puts

    mov ah, 0
    int 16h     ; wait for keypress
   
    ; ACPI shutdown
;    mov ax, 0x07      ; ACPI shutdown command
;    out 0xB2, al       ; Write to the ACPI control port (commonly 0xB2)
    
    mov si, msg_power_off
    call puts

    ; BIOS power off
    mov ax, 0x5307     ; APM power-off function
    mov bx, 0x0001     ; APM device ID (all devices)
    int 0x15           ; Call BIOS

    mov si, msg_powered_off
    call puts

    mov si, msg_any_key
    call puts

    mov ah, 0
    int 16h            ; wait for keypress

    mov si, msg_reboot
    call puts
    
    jmp 0FFFFh:0    ; jump to beginning of BIOS. Should reboot.
    cli
    hlt
section .data

msg_hello:              db 'Hello world!', CR, LF ,0
msg_any_key:            db 'Press any key...', CR, LF, 0
msg_power_off:          db 'Powering off...', CR, LF, 0
msg_reboot:             db 'Reboot...', CR, LF, 0
msg_powered_off:        db 'Powered off!', CR, LF, 0       

;times 510-($-$$) db 0
dw 0AA55h

section .bss 
SPACE equ 2048
kernel_stack: resb SPACE