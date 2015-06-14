; ------------------------------------------------------------------------------
;
; File : text_buffer.asm
;
; Code that handles a text buffer on the TDA format, were a word is a
; color/character pair
;
; ------------------------------------------------------------------------------
    section .text
    .global PUTS
    .global PUTC
    .global PUT_UDEC
    .global PUT_UHEX
    .global PUT_UWHEX
    .global PUT_UBHEX
    .global SYNC_HW_CURSOR


    .include "constants.ainc"
    .include "ram_vars.ainc"
; Puts a null terminated string on the screen buffer and increases cursor position
;   %r0 Ptr to string (not preserved)
;   %r1 String max lenght (not preserved)
; Pollutes %r3, %r4, %r5, %r6 and %flags
PUTS:
    ifle %r1, 0               ; while (len > 0)
      jmp PUTS_END
    loadb %r2, %r0            ; Read character
    ifeq %r2, 0               ; if (c == null) break
      jmp PUTS_END

    call PUTC                 ; Print it
    sub %r1, %r1, 1           ; len--
    add %r0, %r0, 1           ; ptr++
    jmp PUTS

PUTS_END:
    ret

; Puts a single character on the screen buffer and increases cursor position
;   %r2 char to put on it
; Pollutes %r3, %r4, %r5, %r6 and %flags
PUTC:
    ifeq %r2, 0x0A          ; If is \n
      jmp PUTC_NEXT_LINE
    ifeq %r2, 0x08          ; If is backspace
      jmp PUTC_DELETE

    ; Gets cursor and calcs offset
    loadb %r5, CURSOR_COL   ; Grabs column
    lls %r3, %r5, 1         ; Col x2, as we use a word for a attribute/char pair

    loadb %r4, CURSOR_ROW   ; Grab row
    mul %r6, %r4, 80        ; 40*2 as an word is a pair attribute + char
    add %r6, %r6, %r3       ; offset = col*2 + row * max_col*2

    storeb %r6, SCREEN_BUFF, %r2  ; buffer[offset] = character

    add %r5, %r5, 1         ; Increase column
    ifl %r5, 40             ; If not wraps colum, end
      jmp PUTC_END
    mov %r5, 0
    add %r4, %r4, 1         ; Increase row
    ifl %r4, 30             ; If not wraps row, end
      jmp PUTC_END
    mov %r4, 0

    jmp PUTC_END

PUTC_DELETE:
    loadb %r5, CURSOR_COL   ; Grabs column
    loadb %r4, CURSOR_ROW   ; Grab row
    sub %r5, %r5, 1
    ifclear %flags, 2       ; If NOT overflows
      jmp PUTC_DELETE_END
    mov %r5, 0
    sub %r4, %r4, 1
    ifbits %flags, 2        ; If NOT overflows
      mov %r4, 0

PUTC_DELETE_END:
    lls %r3, %r5, 1         ; Col x2, as we use a word for a attribute/char pair
    mul %r6, %r4, 80        ; 40*2 as an word is a pair attribute + char
    add %r6, %r6, %r3       ; offset = col*2 + row * max_col*2
    mov %r3, 0x20
    storeb %r6, SCREEN_BUFF, %r3  ; Clean the character cell

    jmp PUTC_END

PUTC_END:
    storeb CURSOR_COL, %r5  ; Writes to ram the new cursor position
    storeb CURSOR_ROW, %r4  ; row
    ret

PUTC_NEXT_LINE:
    mov %r2, ' '
    call PUTC               ; Recursive call to print a space

    loadb %r5, CURSOR_COL   ; Grabs column
    ifeq %r5, 0             ; Wrapped, so we end
      ret

    jmp PUTC_NEXT_LINE      ; Loops to fill the line with spaces


; Prints an unsigned double word
;   %r0 unsigned double word with the value
; Pollutes %r1, %r2, %r3, %r4, %r5, %r6, %y and %flags
PUT_UDEC:
    mov %r1, 0

PUT_UDEC_DOLOOP:
    div %r0, %r0, 10
    add %r2, %y, '0'          ; Convert the rest to a character
    push %r2                  ; We must use the stack to reverse the order
    add %r1, %r1, 1           ; %r1 contains the number of characters pushed
    ifg %r0, 0                ; while %r0 / 10 > 0
      jmp PUT_UDEC_DOLOOP

PUT_UDEC_WHILELOOP:
    ifl %r1, 1                ; while (%r1 >= 1)
      jmp PUT_UDEC_END

    pop %r2                   ; Grabs the character
    sub %r1, %r1, 1

    call PUTC                 ; Print it
    jmp PUT_UDEC_WHILELOOP

PUT_UDEC_END:
    ret


; Prints an unsigned double word on Hexadecimal
;   %r0 unsigned byte with the value
; Pollutes %r0, %r2, %r3, %r4, %r5, %r6 and %flags
PUT_UHEX:
    push %r0
    lrs %r0, %r0, 16          ; High word first
    call PUT_UWHEX

    pop %r0
    and %r0, %r0, 0xFFFF      ; Fallback to PUT_UWHEX

; Prints an unsigned word on Hexadecimal
;   %r0 unsigned byte with the value
; Pollutes %r0, %r2, %r3, %r4, %r5, %r6 and %flags
PUT_UWHEX:
    push %r0
    lrs %r0, %r0, 8           ; High byte first
    call PUT_UBHEX

    pop %r0
    and %r0, %r0, 0xFF        ; Fallback to PUT_UBHEX

; Prints an unsigned byte on Hexadecimal
;   %r0 unsigned byte with the value
; Pollutes %r2, %r3, %r4, %r5, %r6 and %flags
PUT_UBHEX:
    lrs %r2, %r0, 4           ; High nibble first
    call PUT_HEX
    and %r2, %r0, 0x0F        ; Fallback to PUT_HEX

; Prints a single hexadecimal digit
;   %r2 (lowest nibble) with the hexadecimal digit
; Pollutes %r2, %r3, %r4, %r5, %r6 and %flags
PUT_HEX:
    add %r2, %r2, '0'
    ifle %r2, '9'
      jmp PUT_HEX_PUT
    add %r2, %r2, 7           ; %r2 += ('A' - '0')

PUT_HEX_PUT:
    call PUTC

    ret

; Sets the HW cursor to the text buffer cursor position
SYNC_HW_CURSOR:
    push %r5
    push %r4

    loadb %r5, CURSOR_COL   ; Grabs column
    loadb %r4, CURSOR_ROW   ; Grab row
    lls %r4, %r4, 8
    or %r5, %r5, %r4
    load %r6, HW_CURSOR_ADDR
    storew %r6, %r5         ; Sets HW cursor column and row

    pop %r4
    pop %r5
    ret

; vim: set filetype=asmtr32 :
