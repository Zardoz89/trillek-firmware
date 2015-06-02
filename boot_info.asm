; ------------------------------------------------------------------------------
;
; File : boot_info.asm
;
; Prints on the screen some information
;
; ------------------------------------------------------------------------------


    loadb %r3, PRIMARY_GRAPH
    ifeq %r1, 0xFF
      jmp SKIP_PRINT            ; No screen, no print

    ; Print total RAM
    mov %r0, STR_RAM_OK
    mov %r1, 18
    call PUTS

    load %r0, TOP_RAM_ADDR
    lrs %r0, %r0, 10            ; Divide by 1024
    call PUT_UDEC

    mov %r0, STR_RAM_BYTES
    mov %r1, 4
    call PUTS

    mov %r0, 0x0100
    storew CURSOR_COL, %r0      ; Reposionate to row 1, col 0

    loadb %r0, TOTAL_DEVICES    ; Print number of devices
    call PUT_UDEC

    mov %r0, STR_DEVICES
    mov %r1, 18
    call PUTS

    mov %r0, 0x0200
    storew CURSOR_COL, %r0      ; Reposionate to row 2, col 0

    ; Print "Graphics card at slot : X"
    mov %r0, STR_GRAPH_CARD_AT
    mov %r1, 26
    call PUTS
    loadb %r0, PRIMARY_GRAPH    ; Print slot of the graphic card
    call PUT_UDEC

    mov %r0, 0x0300
    storew CURSOR_COL, %r0      ; Reposionate to row 3, col 0

    loadb %r3, PRIMARY_KEYB
    ifeq %r1, 0xFF
      jmp SKIP_PRINT
    ; Print "Keyboard at slot : X"
    mov %r0, STR_KEYBOARD_CARD_AT
    mov %r1, 21
    call PUTS
    loadb %r0, PRIMARY_KEYB     ; Print slot of the graphic card
    call PUT_UDEC

    ; Print Floppy list
    loadw %r0, CURSOR_COL
    add %r0, %r0, 0x0100
    and %r0, %r0, 0xFF00        ; Jumps to the next row
    storew CURSOR_COL, %r0

    mov %r0, STR_FLOPPY_LIST
    mov %r1, 27
    call PUTS

SKIP_PRINT:
    mov %r10, 0                     ; r10 as list index
    mov %r9, 0											; r9 to count floppy unit
INFO_FLOPPY_FOR:

    loadb %r1, %r10, DEVICES_TABLE

    lls %r2, %r1, 8
    add %r2, %r2, BASE_ENUM_CTROL   ; %r2 points to device registers

		loadb %r3, %r2, 1								; Reads type
    ifneq %r3, DEV_TYPE_MSTORAGE
      jmp INFO_FLOPPY_FOR_NEXT      ; Skips to the next iteration

		loadb %r3, %r2, 2								; Reads subtype
    ifneq %r3, 0x01                 ; If not is a 5.25 Floppy drive
      jmp INFO_FLOPPY_FOR_NEXT      ; Skips to the next iteration

		push %r0
		push %r1
    mov %r0, STR_FLOPPY_FDX
    mov %r1, 3
    call PUTS												; Print "FD"
		pop %r1
		pop %r0

		mov %r0, %r9
    call PUT_UDEC                   ; Print slot of the floppy drive

    mov %r2, ' '
    call PUTC

		add %r9, %r9, 1									; How many floppy units there is ?

INFO_FLOPPY_FOR_NEXT:
    add %r10, %r10, 1
		loadb %r8, TOTAL_DEVICES				; How many items ?
    ifl %r10, %r8
      jmp INFO_FLOPPY_FOR           ; for (%r10=0; %r10 < total_devices; %r10++)

		storeb TOTAL_FD, %r9						; Stores how many floppy drives there are

    loadw %r0, CURSOR_COL
    add %r0, %r0, 0x0100
    and %r0, %r0, 0xFF00        ; Jumps to the next row
    storew CURSOR_COL, %r0

; vim: set filetype=asmtr32 :
