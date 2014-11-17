; ------------------------------------------------------------------------------
;
; File : text_buffer.asm
;
; Code that handles a text buffer on the TDA format, were a word is a
; color/character pair
;
; ------------------------------------------------------------------------------


; Puts a null terminated string on the screen buffer and increases cursor position
;   %r0 Ptr to string (not preserved)
;   %r1 String max lenght (not preserved)
; Pollutes %r3, %r4, %r5, %r6 and %flags
PUTS:
  IFLE %r1, 0               ; while (len > 0)
    JMP PUTS_END
  LOADB %r2, %r0            ; Read character
  IFEQ %r2, 0               ; if (c == null) break
    JMP PUTS_END

  CALL PUTC                 ; Print it
  SUB %r1, %r1, 1           ; len--
  ADD %r0, %r0, 1           ; ptr++
  JMP PUTS

PUTS_END:
  RET

; Puts a single character on the screen buffer and increases cursor position
;   %r2 char to put on it
; Pollutes %r3, %r4, %r5, %r6 and %flags
PUTC:
    ; Gets cursor and calcs offset
    LOADB %r5, CURSOR_COL   ; Grabs column
    LLS %r3, %r5, 1         ; Col x2, as we use a word for a attribute/char pair

    LOADB %r4, CURSOR_ROW   ; Grab row
    MUL %r6, %r4, 80        ; 40*2 as an word is a pair attribute + char
    ADD %r6, %r6, %r3       ; offset = col*2 + row * max_col*2

    STOREB %r6, SCREEN_BUFF, %r2  ; buffer[offset] = character

    ADD %r5, %r5, 1         ; Increase column
    IFL %r5, 40             ; If not wraps colum, end
      JMP PUTC_END
    MOV %r5, 0
    ADD %r4, %r4, 1         ; Increase row

PUTC_END:
    STOREB CURSOR_COL, %r5  ; Writes to ram the new cursor position
    STOREB CURSOR_ROW, %r4  ; row
    RET

