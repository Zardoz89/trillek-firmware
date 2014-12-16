; ------------------------------------------------------------------------------
;
; File : ram_vars.asm
; Firmware variable and data placed on RAM
;
; NOTE : As actually WaveAsm make flat binary files, we not use here .dX as
;        would insert sleeps before the real code. Instead, we use .EQU
;
; ------------------------------------------------------------------------------

    .org 0x0   ; Ram vars are emplaced at address 0 and forwards
INT_VECTOR_TABLE: .reserve 256*4
    ; Each interrupt handler pointer takes 4 bytes
    ; So we reserve the first 1024 bytes for the vector table

TOP_RAM_ADDR:     .dw 0       ; Top address of RAM (ie size) (dw 1024)
FIRM_INITIATED:   .db 0       ; Internal var. Must be 0xFF (b 1028)
TOTAL_FD:					.db 0       ; How many floppy drives there is (b 1276)
PRIMARY_KEYB:     .db 0       ; Slot were is the primary keyboard (b 1277)
PRIMARY_GRAPH:    .db 0       ; Slot were is the primary graphics card (b 1278)
TOTAL_DEVICES:    .db 0       ; Number of devices (b 1279)

DEVICES_TABLE:    .reserve 220; Device lists were each entry is a byte with
															; that indicates a slot with a device
                              ; Max size = 32 bytes
                              ; But we reserve 220 bytes -> 0x500 to 0x5DC
															; (1280 to 1500)

CURSOR_COL:       .db 0       ; Cursor column (b 1032)
CURSOR_ROW:       .db 0       ; Cursor row    (b 1033)
HW_CURSOR_ADDR:   .dw 0       ; Address of Hardware cursor position (dw 1036)

    .rorg 0x600
                              ; iHere begins the screen buffer used by the
                              ; firmware (1536), ends at 0xF60 (3936)
SCREEN_BUFF:      .reserve TDA_TEXTBUFF_SIZE
    .rend

