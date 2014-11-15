; ------------------------------------------------------------------------------
;
; File : aux_functions.asm
;
; Misc subrutines to
;
; ------------------------------------------------------------------------------

; DW_MEMSET fills a RAM region with double words
;   %r0 Pointer to were write
;   %r1 Fill DWord
;   %r2 Size on Double words (bytes / 4). Unsigned double word
;   %r2, %r3 and %flags values not preserved
DW_MEMSET:
    MOV %r3, 0
    LLS %r2, %r2, 2         ; x4 -> %r2 now in bytes

DW_MEMSET_WHILE_LOOP:       ; while (%r3 < %r2)
    IFGE %r3, %r2
      JMP DW_MEMSET_END

    STORE %r0, %r3, %r1
    ADD %r3, %r3, 4
    JMP DW_MEMSET_WHILE_LOOP

DW_MEMSET_END:
    RET

