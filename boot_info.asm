; ------------------------------------------------------------------------------
;
; File : boot_info.asm
;
; Prints on the screen some information
;
; ------------------------------------------------------------------------------


    LOADB %r3, PRIMARY_GRAPH
    IFEQ %r1, 0xFF
      JMP SKIP_PRINT            ; No screen, no print

    ; Print total RAM
    MOV %r0, STR_RAM_OK
    MOV %r1, 18
    CALL PUTS

    LOAD %r0, TOP_RAM_ADDR
    LRS %r0, %r0, 10            ; Divide by 1024
    CALL PUT_UDEC

    MOV %r0, STR_RAM_BYTES
    MOV %r1, 4
    CALL PUTS

    MOV %r0, 0x0100
    STOREW CURSOR_COL, %r0      ; Reposionate to row 1, col 0

    LOADB %r0, TOTAL_DEVICES    ; Print number of devices
    CALL PUT_UDEC

    MOV %r0, STR_DEVICES
    MOV %r1, 18
    CALL PUTS

    MOV %r0, 0x0200
    STOREW CURSOR_COL, %r0      ; Reposionate to row 2, col 0

    ; Print "Graphics card at slot : X"
    MOV %r0, STR_GRAPH_CARD_AT
    MOV %r1, 26
    CALL PUTS
    LOADB %r0, PRIMARY_GRAPH    ; Print slot of the graphic card
    CALL PUT_UDEC

    MOV %r0, 0x0300
    STOREW CURSOR_COL, %r0      ; Reposionate to row 3, col 0

    LOADB %r3, PRIMARY_KEYB
    IFEQ %r1, 0xFF
      JMP SKIP_PRINT
    ; Print "Keyboard at slot : X"
    MOV %r0, STR_KEYBOARD_CARD_AT
    MOV %r1, 21
    CALL PUTS
    LOADB %r0, PRIMARY_KEYB     ; Print slot of the graphic card
    CALL PUT_UDEC

    ; Print Floppy list
    LOADW %r0, CURSOR_COL
    ADD %r0, %r0, 0x0100
    AND %r0, %r0, 0xFF00        ; Jumps to the next row
    STOREW CURSOR_COL, %r0

    MOV %r0, STR_FLOPPY_LIST
    MOV %r1, 27
    CALL PUTS

    MOV %r10, 0                     ; r10 as index
INFO_FLOPPY_FOR:

    LLS %r0, %r10, 1                ; x2
    LOADW %r1, %r0, DEVICES_TABLE
    LRS %r2, %r1, 8                 ; Pick only Dev Type
    IFNEQ %r2, DEV_TYPE_MSTORAGE
      JMP INFO_FLOPPY_FOR_NEXT      ; Skips to the next iteration

    AND %r1, %r1, 0xFF              ; Pick only Slot
    LLS %r2, %r1, 8
    ADD %r2, %r2, 2                 ; Dev. subtype offset
    LOADB %r2, %r2, BASE_ENUM_CTROL ; Reads subtype
    IFNEQ %r2, 0x01                 ; If not is a 5.25 Floppy drive
      JMP INFO_FLOPPY_FOR_NEXT      ; Skips to the next iteration

    MOV %r0, %r1
    CALL PUT_UDEC                   ; Print slot of the floppy drive

    MOV %r2, ','
    CALL PUTC
    MOV %r2, ' '
    CALL PUTC

INFO_FLOPPY_FOR_NEXT:
    ADD %r10, %r10, 1
    IFL %r10, 32
      JMP INFO_FLOPPY_FOR           ; for (%r10=0; %r10 < 32; %r10++)

SKIP_PRINT:
