; ------------------------------------------------------------------------------
;
; File : ram_vars.asm
; Firmware variable and data placed on RAM
;
; NOTE : As actually WaveAsm make flat binary files, we not use here .dX as
;        would insert sleeps before the real code. Instead, we use .ORG or .EQU
;
; ------------------------------------------------------------------------------

.ORG 0  

INT_VECTOR_TABLE: 
    ; Each interrupt handler pointer takes 4 bytes
    ; So we reserve the first 1024 bytes for the vector table

.ORG 1024
TOP_RAM_ADDR: ; Top address of RAM (ie size)

.ORG 1028
; TODO Other vars..

