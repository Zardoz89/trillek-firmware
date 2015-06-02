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

PROMPT        .equ '*'
ADDR_SEP      .equ ':'

CR            .equ 0x0D         ; Enter key
LF            .equ 0x0A         ; \n
DEL           .equ 0x08         ; Delete key

CURSOR        .equ 0b1111000011101010 ; Configuration of the HW cursor

; Ram vars
MKEYB_ADDR:       .equ 0x1000 ; (dw) Keyboard base address
LADDRESS:         .equ 0x1004 ; (dw) Last address pointed
WRITE_IND:        .equ 0x1008 ; (b) Write index
MBUFFER_COUNT:    .equ 0x1009 ; (b) Buffer size
MBUFFER:          .equ 0x100A ; (max 255) Buffer size

; Code

MONITOR_ENTRY:
    loadw %r0, CURSOR_COL
    add %r0, %r0, 0x0100
    and %r0, %r0, 0xFF00        ; Jumps to the next row
    storew CURSOR_COL, %r0

    loadb %r0, PRIMARY_KEYB
    lls %r0, %r0, 8
    or %r0, %r0, 0x110000       ; Base address of the keyboard at 0x11XX00
    store MKEYB_ADDR , %r0

    mov %r0, 0
    storeb MBUFFER_COUNT, %r0   ; Set buffer counter to 0

    mov %r0, 0x001400
    store LADDRESS, %r0         ; Set last address to 0x001400

    load %r6, HW_CURSOR_ADDR    ; Enables blinking HW cursor
    mov %r0, CURSOR
    storew %r6, -2, %r0

MONITOR_PROMPT:
    mov %r2, PROMPT
    call PUTC
    call SYNC_HW_CURSOR

MONITOR_GETCHAR:
    load %r0, MKEYB_ADDR
MONITOR_GETCHAR_WAITLOOP:       ; Busy loop to wait a key
    loadw %r1, %r0, 0x12
    ifeq %r1, 0
      jmp MONITOR_GETCHAR_WAITLOOP  ; No key

    mov %r1, 0x0001             ; POP-KEY command
    storew %r0, 0x08, %r1

    loadw %r2, %r0, 0x0A        ; Get Key Code

; Process input from %r2, putting on the buffer and displaying it
MONITOR_PROCESS_INPUT:
    ifeq %r2, CR                ; Enter key
      jmp MONITOR_PARSE
    ifeq %r2, DEL               ; Delete
      jmp MONITOR_DEL

    ifge %r2, 'a'               ; hex
      ifle %r2, 'f'
        jmp MONITOR_PUTBUFFER
    ifge %r2, 'A'
      ifle %r2, 'F'
        jmp MONITOR_PUTBUFFER
    ifge %r2, '0'
      ifle %r2, '9'
        jmp MONITOR_PUTBUFFER

    ifeq %r2, ' '               ; Separator
      jmp MONITOR_PUTBUFFER
    ifeq %r2, '.'               ; List block
      jmp MONITOR_PUTBUFFER
    ifeq %r2, ':'               ; Put data
      jmp MONITOR_PUTBUFFER

    ifeq %r2, 'r'               ; Run command
      jmp MONITOR_PUTBUFFER
    ifeq %r2, 'R'
      jmp MONITOR_PUTBUFFER

    jmp MONITOR_GETCHAR_WAITLOOP  ; Unknow, or not an actual command

MONITOR_PUTBUFFER:
    loadb %r0, MBUFFER_COUNT    ; Get buffer size
    storeb %r0, MBUFFER, %r2    ; Put it on the buffer
    add %r0, %r0, 1
    storeb MBUFFER_COUNT, %r0   ; Update buffer lenght

    call PUTC
    call SYNC_HW_CURSOR

    jmp MONITOR_GETCHAR

MONITOR_DEL:
    loadb %r0, MBUFFER_COUNT    ; Get buffer size
    ifeq %r0, 0
      jmp MONITOR_GETCHAR       ; Nothing to delete

    sub %r0, %r0, 1
    storeb MBUFFER_COUNT, %r0   ; Update buffer lenght

    call PUTC
    call SYNC_HW_CURSOR

    jmp MONITOR_GETCHAR

; Parsing of the buffer
MONITOR_PARSE:
    ; Jumps to the next line
    mov %r2, LF
    call PUTC
    ; r7 Value
    ; r8 Mode
    ; r9 Buffer index
    ; r10 Buffer size
    mov %r7, 0
    mov %r8, MODE_EXAM          ; Examine mode by default
    mov %r9, 0                  ; Index at 0
    loadb %r10, MBUFFER_COUNT   ; Get buffer size

MONITOR_PARSE_FORLOOP:
    ifge %r9, %r10
      jmp MONITOR_PARSE_END

    loadb %r0, %r9, MBUFFER     ; Load on %r0, buffer[index]
    ifeq %r0, 'R'
      jmp MONITOR_RUN
    ifeq %r0, 'r'
      jmp MONITOR_RUN

    ifeq %r0, ' '
      ifeq %r8, MODE_EXAM
        jmp MONITOR_NEW_LADDR

    ifeq %r0, ' '
      ifeq %r8, MODE_STORE
        jmp MONITOR_WRITEVAL

    ifeq %r0, '.'
      ifeq %r8, MODE_EXAM        ; Only if is in Examination mode
        jmp MONITOR_CHMODE_BEXAM  ; Changes to block examine mode

    ifeq %r0, ':'
      ifeq %r8, MODE_EXAM        ; Only if is in Examination mode
        jmp MONITOR_CHMODE_STORE  ; Changes to store mode

    ifle %r0, '9'               ; 0 to 9
      jmp MONITOR_VAL_HDIGIT

    ifle %r0, 'F'               ; A to F
      jmp MONITOR_VAL_HULETTER
    ifle %r0, 'f'               ; a to f
      jmp MONITOR_VAL_HLLETTER

MONITOR_PARSE_FORNEXT:
    add %r9, %r9, 1
    jmp MONITOR_PARSE_FORLOOP

; Called when the parser ends of reading the buffer
MONITOR_PARSE_END:
    ifeq %r8, MODE_EXAM
      ifneq %r9, 0                ; If not was introduced a value, preserves it
        store LADDRESS, %r7       ; Updates last address

    ifeq %r8, MODE_BEXAM          ; Block examine mode
      jmp MONITOR_PARSE_END_BEXAM

    ifeq %r8, MODE_STORE          ; Store mode
      jmp MONITOR_PARSE_END_STORE

MONITOR_PARSE_END_EXAM:
    ; Print value at last address always
    load %r0, LADDRESS            ; Get last address
    call MONITOR_PRINT_ADDR       ; Print address

    load %r1, LADDRESS            ; Get last address
    loadb %r0, %r1                ; Get value
    call PUT_UBHEX

MONITOR_PARSE_REAL_END:
    ; Jumps to the next line
    mov %r2, LF
    call PUTC

    mov %r0, 0
    storeb MBUFFER_COUNT, %r0   ; Cleans the buffer lenght

    jmp MONITOR_PROMPT

; Stuff to do at the end of parsing when is in block examine mode
MONITOR_PARSE_END_BEXAM:
    load %r0, LADDRESS
    ifg %r0, %r7                ; Invalid end address, display only LADDRESS
      jmp MONITOR_PARSE_END_EXAM

    call MONITOR_PRINT_ADDR     ; Print address

    mov %r10, 0                 ; %r2 as counter to print regular address
MONITOR_PARSE_BEXAM_FORLOOP:
    ifge %r0, %r7               ; for (;%r0 < %r7; %r0++)
      jmp MONITOR_PARSE_BEXAM_FOREND

    ; every 8 values, jump to a new line and print address
    ifneq %r10, 8
      jmp MONITOR_PARSE_BEXAM_PRINTVAL

    mov %r10, 0
    mov %r2, LF                 ; Jumps to the next line
    call PUTC
    call MONITOR_PRINT_ADDR     ; Print address

MONITOR_PARSE_BEXAM_PRINTVAL:
    push %r0                    ; PUT_UBHEX takes value on %r0, so we must
                                ; preserve it
    loadb %r0, %r0              ; Get value at %r0 address and print it
    call PUT_UBHEX

    mov %r2, ' '                ; Separator between values
    call PUTC
    pop %r0

MONITOR_PARSE_BEXAM_FORNEXT:
    add %r0, %r0, 1
    add %r10, %r10, 1
    jmp MONITOR_PARSE_BEXAM_FORLOOP

MONITOR_PARSE_BEXAM_FOREND:

    jmp MONITOR_PARSE_REAL_END

; Stuff to do at the end of parsing when is on store mode
MONITOR_PARSE_END_STORE:
    ifeq %r0, ' '
      jmp MONITOR_PARSE_REAL_END  ; We wrote the last value

    load %r0, LADDRESS
    loadb %r1, WRITE_IND
    storeb %r0, %r1, %r7      ; Writes on %r0 + WRITE_IND

    add %r1, %r1, 1
    storeb WRITE_IND, %r1     ; And increases WRITE_IND

    jmp MONITOR_PARSE_REAL_END

; Execute code pointed at last address
MONITOR_RUN:
    load %r6, HW_CURSOR_ADDR    ; Disables blinking HW cursor
    mov %r0, 0
    storew %r6, -2, %r0

    load %r0, LADDRESS          ; Get last address
    call %r0

    load %r6, HW_CURSOR_ADDR    ; Enables blinking HW cursor
    mov %r0, CURSOR
    storew %r6, -2, %r0

    jmp MONITOR_PARSE_END

; Changes to Block EXAMine mode
MONITOR_CHMODE_BEXAM:
    ifneq %r9, 0                ; If not was introduced a value, preserves it
      store LADDRESS, %r7

    mov %r8, MODE_BEXAM
    mov %r7, 0                  ; Resets temporal value

    jmp MONITOR_PARSE_FORNEXT

; Changes to STORE mode
MONITOR_CHMODE_STORE:
    ifneq %r9, 0                ; If not was introduced a value, preserves it
      store LADDRESS, %r7

    mov %r8, MODE_STORE
    mov %r7, 0                  ; Resets temporal value
    storeb WRITE_IND, %r7       ; Sets write index to 0

    jmp MONITOR_PARSE_FORNEXT

; Changes last address and print it
MONITOR_NEW_LADDR:
    store LADDRESS, %r7

    mov %r0, %r7
    call MONITOR_PRINT_ADDR   ; Print address

    loadb %r0, %r7            ; Print value
    call PUT_UBHEX

    ; Jumps to the next line
    mov %r2, LF
    call PUTC

    mov %r7, 0                ; Reset temporal

    jmp MONITOR_PARSE_FORNEXT

; Writes %r7 value on LADDRESS
MONITOR_WRITEVAL
    load %r0, LADDRESS
    loadb %r1, WRITE_IND
    storeb %r0, %r1, %r7      ; Writes on %r0 + WRITE_IND

    add %r1, %r1, 1
    storeb WRITE_IND, %r1     ; And increases WRITE_IND

    mov %r7, 0                ; Reset temporal

    jmp MONITOR_PARSE_FORNEXT

; Shift to the left value and add (0-9)
MONITOR_VAL_HDIGIT:
    lls %r7, %r7, 4
    sub %r0, %r0, '0'
    and %r0, %r0, 0x0F        ; Sanization
    or %r7, %r7, %r0
    jmp MONITOR_PARSE_FORNEXT

; Shift to the left value and add (A-F) uppercase
MONITOR_VAL_HULETTER:
    lls %r7, %r7, 4
    sub %r0, %r0, 0x37        ; ('A' - 0x0A)
    and %r0, %r0, 0x0F        ; Sanization
    or %r7, %r7, %r0
    jmp MONITOR_PARSE_FORNEXT

; Shift to the left value and add (A-F) lowercase
MONITOR_VAL_HLLETTER:
    lls %r7, %r7, 4
    sub %r0, %r0, 0x57        ; ('a' - 0x0A)
    and %r0, %r0, 0x0F        ; Sanization
    or %r7, %r7, %r0
    jmp MONITOR_PARSE_FORNEXT

; Subrutine that print and addres on %r0
MONITOR_PRINT_ADDR:
    push %r0
    call PUT_UHEX

    mov %r2, ADDR_SEP
    call PUTC
    mov %r2, ' '
    call PUTC

    pop %r0
    ret

; vim: set filetype=asmtr32 :
