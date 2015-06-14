; ------------------------------------------------------------------------------
;
; File : aux_functions.asm
;
; Misc subrutines to
;
; ------------------------------------------------------------------------------
    section .text
    .global DW_MEMSET

    .include "constants.ainc"
    .include "ram_vars.ainc"
; DW_MEMSET fills a RAM region with double words
;   %r0 Pointer to were write
;   %r1 Fill DWord
;   %r2 Size on Double words (bytes / 4). Unsigned double word
;   %r2, %r3 and %flags values not preserved
DW_MEMSET:
    mov %r3, 0
    lls %r2, %r2, 2         ; x4 -> %r2 now in bytes

DW_MEMSET_WHILE_LOOP:       ; while (%r3 < %r2)
    ifge %r3, %r2
      jmp DW_MEMSET_END

    store %r0, %r3, %r1
    add %r3, %r3, 4
    jmp DW_MEMSET_WHILE_LOOP

DW_MEMSET_END:
    ret

; vim: set filetype=asmtr32 :
