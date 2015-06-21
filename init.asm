; ------------------------------------------------------------------------------
;
; File : init.asm
; Entry point of the Trillek computer firmware
;
; The first thing that does, is a quick check of how much RAM memory there is
; and sets the stack
;
; ------------------------------------------------------------------------------

RAM_HARDCHECK .equ 0x2000      ; How many bytes are "hard" checked (8 KiB)
RAM_STEP      .equ 0x2000      ; Jumps of 8 KiB

QUICK_RAM_CHECK:
    mov %r0, 0xAAAAAAAA   ; Test pattern
    mov %r1, 0            ; %r1 is a pointer
QRC_DOLOOP1:
    store %r1, %r0        ; Writes test pattern at %r1
    load %r2, %r1         ; Read from %r1
    ifneq %r0, %r2        ; If %r2 != %r0 something is very wrong at this stage
      rjmp ERROR_RAM
    add %r1, %r1, 4       ; Increments counter
    ifl %r1, RAM_HARDCHECK ; while %r1 < RAM_HARDCHECK
      rjmp QRC_DOLOOP1
    ; From here, we can assume that there is at least 8 KiB of RAM

    mov %r0, 0xAA         ; New test pattern
    mov %r1, 0            ; Reset pointer
QRC_DOLOOP2:
    add %r1, %r1, RAM_STEP ; Checks a byte every step
    storeb %r1, %r0       ; Writes test pattern at %r1
    loadb %r2, %r1        ; Read from %r1
    ifeq %r0, %r2         ; while %r2 == %r0
      rjmp QRC_DOLOOP2

    ; TODO Do a fine check of the last RAM_STEP bytes

    ;sub %r1, %r1, RAM_STEP  ; %r1 points now to the hights valid ram address
    store TOP_RAM_ADDR, %r1 ; Store on ram were is the top valid address
    mov %sp , %r1          ; Setstack at the highest valid ram address
    rjmp RAM_OK

ERROR_RAM:                ; RAM is broken
    ; TODO Do a beep squence to indicate bad RAM
    jmp CRASH

RAM_OK:                   ; Firmware next step

; vim: set filetype=asmtr32 :
