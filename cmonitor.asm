; ------------------------------------------------------------------------------
;
; File : cmonitor.asm
; Woz's Monitor clone for Trillek Computer v0.1.0
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

    MOV %r0, 0
    STOREB MBUFFER_COUNT, %r0   ; Set buffer counter to 0

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

; Process input from %r2, putting on the buffer and displaying it
MONITOR_PROCESS_INPUT:
    IFEQ %r2, 0x0D              ; Enter key
      JMP MONITOR_PARSE
    IFEQ %r2, 0x08              ; Delete
      JMP MONITOR_DEL

    IFGE %r2, 'a'               ; hex
      IFLE %r2, 'f'
        JMP MONITOR_PUTBUFFER
    IFGE %r2, 'A'
      IFLE %r2, 'F'
        JMP MONITOR_PUTBUFFER
    IFGE %r2, '0'
      IFLE %r2, '9'
        JMP MONITOR_PUTBUFFER

    IFEQ %r2, ' '               ; Separator
      JMP MONITOR_PUTBUFFER
    IFEQ %r2, '.'               ; List block
      JMP MONITOR_PUTBUFFER
    IFEQ %r2, ':'               ; Put data
      JMP MONITOR_PUTBUFFER

    IFEQ %r2, 'r'               ; Run command
      JMP MONITOR_PUTBUFFER
    IFEQ %r2, 'R'
      JMP MONITOR_PUTBUFFER

    JMP MONITOR_GETCHAR_WAITLOOP  ; Unknow, or not an actual command

MONITOR_PUTBUFFER:
    LOADB %r0, MBUFFER_COUNT    ; Get buffer index
    STOREB %r0, MBUFFER, %r2    ; Put it on the buffer
    ADD %r0, %r0, 1
    STOREB MBUFFER_COUNT, %r0   ; Update buffer lenght

    CALL PUTC

    JMP MONITOR_GETCHAR

MONITOR_DEL:
    LOADB %r0, MBUFFER_COUNT    ; Get buffer index
    IFEQ %r0, 0
      JMP MONITOR_GETCHAR       ; Nothing to delete

    SUB %r0, %r0, 1
    STOREB MBUFFER_COUNT, %r0   ; Update buffer lenght

    CALL PUTC

    JMP MONITOR_GETCHAR

; Parsing of the buffer
MONITOR_PARSE:
    ; TODO

    ; Jumps to the next line
    MOV %r2, '0x0D'
    CALL PUTC

    MOV %r0, 0
    STOREB MBUFFER_COUNT, %r0   ; Cleans the buffer lenght

    JMP MONITOR_PROMT

