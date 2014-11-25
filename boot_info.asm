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

SKIP_PRINT:
