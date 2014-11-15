; ------------------------------------------------------------------------------
;
; File : ram_vars.asm
; Firmware variable and data placed on RAM
;
; NOTE : As actually WaveAsm make flat binary files, we not use here .dX as
;        would insert sleeps before the real code. Instead, we use .EQU
;
; ------------------------------------------------------------------------------

INT_VECTOR_TABLE: .EQU 0x0
    ; Each interrupt handler pointer takes 4 bytes
    ; So we reserve the first 1024 bytes for the vector table

TOP_RAM_ADDR:     .EQU 0x400  ; 4b (1024)  Top address of RAM (ie size)


PRIMARY_GRAPH:    .EQU 0x7FE  ; Slot were is the primary graphics card
PRIMARY_KEYB:     .EQU 0x7FD  ; Slot were is the primary keyboard
TOTAL_DEVICES:    .EQU 0x7FF  ; 1b (2047)  Number of devices

DEVICES_TABLE:    .EQU 0x800  ; Total_Devices * 2 (2048) Device table were each
                              ; entry have this format :
                              ;   dev_slot : 1b Device slot
                              ;   dev_type : 1b Device type


; TODO Other vars..

