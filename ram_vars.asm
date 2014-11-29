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

TOP_RAM_ADDR:     .EQU 0x400  ; Top address of RAM (ie size) (dw 1024)
FIRM_INITIATED:   .EQU 0x404  ; Internal var. Must be 0xFF (b 1028)

TOTAL_FD:					.EQU 0x4FC  ; How many floppy drives there is (b 1276)
PRIMARY_KEYB:     .EQU 0x4FD  ; Slot were is the primary keyboard (b 1277)
PRIMARY_GRAPH:    .EQU 0x4FE  ; Slot were is the primary graphics card (b 1278)
TOTAL_DEVICES:    .EQU 0x4FF  ; Number of devices (b 1279)

DEVICES_TABLE:    .EQU 0x500  ; Device lists were each entry is a byte with
															; that indicates a slot with a device
                              ; Max size = 32 bytes
                              ; But we reserve 220 bytes -> 0x500 to 0x5DC
															; (1280 to 1500)

CURSOR_COL:       .EQU 0x408  ; Cursor column (b 1032)
CURSOR_ROW:       .EQU 0x409  ; Cursor row    (b 1033)
SCREEN_BUFF:      .EQU 0x600  ; Were begins the screen buffer used by the
                              ; firmware (1536), ends at 0xF60 (3936)

; Monitor vars
MKEYB_ADDR:       .EQU 0x1000 ; (dw) Keyboard base address
MBUFFER_COUNT:    .EQU 0x1004 ; (b) Buffer size
MBUFFER:          .EQU 0x1005 ; (max 255) Buffer size

; TODO Other vars..

