; ------------------------------------------------------------------------------
;
; File : cmonitor.asm
; Woz's Monitor clone for Trillek Compiter v0.1.0
;
; ------------------------------------------------------------------------------

MONITOR_ENTRY:
    LOADW %r0, CURSOR_COL
    ADD %r0, %r0, 0x0100
    AND %r0, %r0, 0xFF00        ; Jumps to the next row
    STOREW CURSOR_COL, %r0

    LOADB %r0, PRIMARY_KEYB
    LLS %r0, %r0, 8
    OR %r0, %r0, 0x110000       ; Base address of the keyboard at 0x11XX00
    STORE MKEYB_ADDR , %r0

MONITOR_PROMT:
    MOV %r2, ']'
    CALL PUTC

MONITOR_GETCHAR:
    LOAD %r0, MKEYB_ADDR
MONITOR_GETCHAR_WAITLOOP:       ; Busy loop to wait a key
    LOADW %r1, %r0, 0x12
    IFEQ %r1, 0
      JMP MONITOR_GETCHAR_WAITLOOP  ; No key

    MOV %r1, 0x0001             ; POP-KEY command
    STOREW %r0, 0x08, %r1

    LOADW %r2, %r0, 0x0A        ; Get Key Code

MONITOR_ECHO:
    CALL PUTC

    ; IFEQ %r2, 0x0A
    ;   JMP MONITOR_PARSE
    ; IFEQ %r2, 127
    ;   JMP MONITOR_DEL

    LOADB %r0, MBUFFER_COUNT    ; Get buffer index
    STOREB %r0, MBUFFER, %r2    ; Put it on the buffer
    ADD %r0, %r0, 1
    STOREB MBUFFER_COUNT, %r0   ; Update buffer index

    JMP MONITOR_GETCHAR



