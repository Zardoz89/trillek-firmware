; ------------------------------------------------------------------------------
;
; File : cmonitor.asm
; Woz's Monitor clone for Trillek Computer v0.1.0
;
; ------------------------------------------------------------------------------

; Constants

MODE_EXAM     .equ  0           ; Examine a single byte
MODE_BEXAM    .equ  1           ; Examine a block
MODE_STORE    .equ  2           ; Write data

PROMPT        .equ 0x5C         ; \
ADDR_SEP      .equ ':'

CR            .equ 0x0D         ; Enter key
LF            .equ 0x0A         ; \n
DEL           .equ 0x08         ; Delete key

; Ram vars
MKEYB_ADDR:       .EQU 0x1000 ; (dw) Keyboard base address
LADDRESS:         .EQU 0x1004 ; (dw) Last address pointed
MBUFFER_COUNT:    .EQU 0x1008 ; (b) Buffer size
MBUFFER:          .EQU 0x1009 ; (max 255) Buffer size

; Code

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

    MOV %r0, 0x001400
    STORE LADDRESS, %r0         ; Set last address to 0x001400

MONITOR_PROMPT:
    MOV %r2, PROMPT
    CALL PUTC
    MOV %r2, LF
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
    IFEQ %r2, CR                ; Enter key
      JMP MONITOR_PARSE
    IFEQ %r2, DEL               ; Delete
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
    LOADB %r0, MBUFFER_COUNT    ; Get buffer size
    STOREB %r0, MBUFFER, %r2    ; Put it on the buffer
    ADD %r0, %r0, 1
    STOREB MBUFFER_COUNT, %r0   ; Update buffer lenght

    CALL PUTC

    JMP MONITOR_GETCHAR

MONITOR_DEL:
    LOADB %r0, MBUFFER_COUNT    ; Get buffer size
    IFEQ %r0, 0
      JMP MONITOR_GETCHAR       ; Nothing to delete

    SUB %r0, %r0, 1
    STOREB MBUFFER_COUNT, %r0   ; Update buffer lenght

    CALL PUTC

    JMP MONITOR_GETCHAR

; Parsing of the buffer
MONITOR_PARSE:
    ; Jumps to the next line
    MOV %r2, LF
    CALL PUTC
    ; r7 Value
    ; r8 Mode
    ; r9 Buffer index
    ; r10 Buffer size
    MOV %r7, 0
    MOV %r8, MODE_EXAM          ; Examine mode by default
    MOV %r9, 0                  ; Index at 0
    LOADB %r10, MBUFFER_COUNT   ; Get buffer size

MONITOR_PARSE_FORLOOP:
    IFGE %r9, %r10
      JMP MONITOR_PARSE_END

    LOADB %r0, %r9, MBUFFER     ; Load on %r0, buffer[index]
    IFEQ %r0, 'R'
      JMP MONITOR_RUN
    IFEQ %r0, 'r'
      JMP MONITOR_RUN

    IFEQ %r0, ' '
      IFEQ %r8, MODE_EXAM
        JMP MONITOR_NEW_LADDR

    IFEQ %r0, '.'
      JMP MONITOR_CHMODE_BEXAM  ; Changes to block examine mode

    IFEQ %r0, ':'
      JMP MONITOR_PARSE_FORNEXT ; TODO

    IFLE %r0, '9'               ; 0 to 9
      JMP MONITOR_VAL_HDIGIT

    IFLE %r0, 'F'               ; A to F
      JMP MONITOR_VAL_HULETTER
    JMP MONITOR_VAL_HLLETTER    ; a to f

MONITOR_PARSE_FORNEXT:
    ADD %r9, %r9, 1
    JMP MONITOR_PARSE_FORLOOP

; Called when the parser ends of reading the buffer
MONITOR_PARSE_END:
    IFEQ %r8, MODE_EXAM
      IFNEQ %r9, 0                ; If not was introduced a value, preserves it
        STORE LADDRESS, %r7       ; Updates last address

    IFEQ %r8, MODE_BEXAM          ; Block examine mode
      JMP MONITOR_PARSE_END_BEXAM

MONITOR_PARSE_END_EXAM:
    ; Print value at last address always
    LOAD %r0, LADDRESS            ; Get last address
    CALL MONITOR_PRINT_ADDR       ; Print address

    LOAD %r1, LADDRESS            ; Get last address
    LOADB %r0, %r1                ; Get value
    CALL PUT_UBHEX

MONITOR_PARSE_REAL_END:
    ; Jumps to the next line
    MOV %r2, LF
    CALL PUTC

    MOV %r0, 0
    STOREB MBUFFER_COUNT, %r0   ; Cleans the buffer lenght

    JMP MONITOR_PROMPT

; Stuff to do at the end of parsing when is in block examine mode
MONITOR_PARSE_END_BEXAM:
    LOAD %r0, LADDRESS
    IFG %r0, %r7                ; Invalid address, display only LADDRESS
      JMP MONITOR_PARSE_END_EXAM

    ; TODO list data from LADDRESS to %r7 if LADDRESS is <= %r7
    CALL MONITOR_PRINT_ADDR   ; Print address

    JMP MONITOR_PARSE_REAL_END

; Execute code pointed at last address
MONITOR_RUN:
    LOAD %r0, LADDRESS          ; Get last address
    CALL %r0
    JMP MONITOR_PARSE_END

; Changes to Block EXAMine mode
MONITOR_CHMODE_BEXAM:
    IFNEQ %r9, 0                ; If not was introduced a value, preserves it
      STORE LADDRESS, %r7

    MOV %r8, MODE_BEXAM
    MOV %r7, 0                  ; Resets temporal value

    JMP MONITOR_PARSE_FORNEXT

; Changes last address and print it
MONITOR_NEW_LADDR:
    STORE LADDRESS, %r7

    MOV %r0, %r7
    CALL MONITOR_PRINT_ADDR   ; Print address

    LOADB %r0, %r7            ; Print value
    CALL PUT_UBHEX

    ; Jumps to the next line
    MOV %r2, LF
    CALL PUTC

    MOV %r7, 0                ; Reset temporal

    JMP MONITOR_PARSE_FORNEXT

; Shift to the left value and add (0-9)
MONITOR_VAL_HDIGIT:
    LLS %r7, %r7, 4
    SUB %r0, %r0, '0'
    AND %r0, %r0, 0x0F        ; Sanization
    OR %r7, %r7, %r0
    JMP MONITOR_PARSE_FORNEXT

; Shift to the left value and add (A-F) uppercase
MONITOR_VAL_HULETTER:
    LLS %r7, %r7, 4
    SUB %r0, %r0, 0x37        ; ('A' - 0x0A)
    AND %r0, %r0, 0x0F        ; Sanization
    OR %r7, %r7, %r0
    JMP MONITOR_PARSE_FORNEXT

; Shift to the left value and add (A-F) lowercase
MONITOR_VAL_HLLETTER:
    LLS %r7, %r7, 4
    SUB %r0, %r0, 0x57        ; ('a' - 0x0A)
    AND %r0, %r0, 0x0F        ; Sanization
    OR %r7, %r7, %r0
    JMP MONITOR_PARSE_FORNEXT

; Subrutine that print and addres on %r0
MONITOR_PRINT_ADDR:
    LOAD %r0, LADDRESS          ; Get last address
    CALL PUT_UHEX

    MOV %r2, ADDR_SEP
    CALL PUTC
    MOV %r2, ' '
    CALL PUTC

    RET

