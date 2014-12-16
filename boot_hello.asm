; ------------------------------------------------------------------------------
;
; File : boot_hello.asm
; Basic example of a bootable disk
;
; ------------------------------------------------------------------------------

PUTS .equ 0x10071c  ; Address of PUTS subrutine

    .org 0x1400

    mov %r0, STR_HELLO
    mov %r1, 13
    call PUTS
    sleep

STR_HELLO:  .db "Hello world!",0


    .org 0x15FC             ; 0x1400 + 512 - 4
    .db "TR32"              ; Boot mark
