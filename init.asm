; ------------------------------------------------------------------------------
;
; File : init.asm
; Entry point of the Trillek computer firmware
;
; The first thing that does, is a quick check of how much RAM memory there is
; and sets the stack
;
; ------------------------------------------------------------------------------

RAM_HARDCHECK .EQU 0x2000      ; How many bytes are "hard" checked (8 KiB)
RAM_STEP      .EQU 0x2000      ; Jumps of 8 KiB

.ORG 0x100000             ; ROM begins at 0x100000
QUICK_RAM_CHECK:
    MOV %r0, 0xAAAAAAAA   ; Test pattern
    MOV %r1, 0            ; %r1 is a pointer
QRC_DOLOOP1:
    STORE %r1, %r0        ; Writes test pattern at %r1
    LOAD %r2, %r1         ; Read from %r1
    IFNEQ %r0, %r2        ; If %r2 != %r0 something is very wrong at this stage
      JMP ERROR_RAM
    ADD %r1, %r1, 4       ; Increments counter
    IFL %r1, RAM_HARDCHECK ; while %r1 < RAM_HARDCHECK
      JMP QRC_DOLOOP1
    ; From here, we can assume that there is at least 8 KiB of RAM

    MOV %r0, 0xAA         ; New test pattern
    MOV %r1, 0            ; Reset pointer
QRC_DOLOOP2:
    ADD %r1, %r1, RAM_STEP ; Checks a byte every step
    STOREB %r1, %r0       ; Writes test pattern at %r1
    LOADB %r2, %r1        ; Read from %r1
    IFEQ %r0, %r2         ; while %r2 == %r0
      JMP QRC_DOLOOP2

    ; TODO Do a fine check of the last RAM_STEP bytes

    ;SUB %r1, %r1, RAM_STEP  ; %r1 points now to the hights valid ram address
    STORE TOP_RAM_ADDR, %r1 ; Store on ram were is the top valid address
    MOV %sp, %r1          ; Setstack at the highest valid ram address
    JMP RAM_OK

ERROR_RAM:                ; RAM is broken
    ; TODO Do a beep squence to indicate bad RAM
    JMP CRASH

RAM_OK:                   ; Firmware next step

