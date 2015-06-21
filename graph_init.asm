; ------------------------------------------------------------------------------
;
; File : graph_init.asm
;
; Initialize the primary graphics card
;
; ------------------------------------------------------------------------------

; 1) Search the first graphic card from the device list and make it primary
; TODO Try to get it from the NVRAM so the user could set it

    mov %r0, 0xFF
    storeb PRIMARY_GRAPH , %r0      ; We mark it as there is none
    mov %r0, 0                      ; counter
		loadb %r10, TOTAL_DEVICES				; How many items ?

SEARCH_GRPH_DOLOOP:
    loadb %r1, %r0, DEVICES_TABLE

    lls %r2, %r1, 8
    add %r2, %r2, BASE_ENUM_CTROL   ; %r2 points to device registers

		loadb %r3, %r2, 1								; Reads type
    ifneq %r3, DEV_TYPE_GRPH
      rjmp SEARCH_GRPH_WHILE_LOOP   ; Skips to the next iteration

		loadb %r3, %r2, 2								; Reads subtype
    ifneq %r3, 0x1                  ; If not is TDA compatible
      rjmp SEARCH_GRPH_WHILE_LOOP   ; Skips to the next iteration

    storeb PRIMARY_GRAPH , %r1      ; We save the device slot
    rjmp INIT_PRIMARY_GRAPH					; break;

SEARCH_GRPH_WHILE_LOOP:
    add %r0, %r0, 1
    ifl %r0, %r10                   ; while (%r0 < %r10)
      rjmp SEARCH_GRPH_DOLOOP

;   TODO Beep sequence to indicate that there is no a graphics card
;    LOADB %r0, PRIMARY_GRAPH
;    IFEQ %r0, 0xFF
;      CALL BEEP_NO_GRAPH_CARD

; 2) Initialize the primary graphics card
INIT_PRIMARY_GRAPH:
    loadb %r0, PRIMARY_GRAPH
    ifeq %r0, 0xFF                  ; There isn't a card to init
      rjmp END_INIT_PRIMARY_GRAPH

    lls %r0, %r0, 8
    add %r0, %r0, BASE_ENUM_CTROL
    add %r1, %r0, 0x12
    store HW_CURSOR_ADDR, %r1       ; Address of were is the HW cursor ctrl (E)

    mov %r1, SCREEN_BUFF
    store %r0, 0x0A, %r1            ; Sets the text buffer
    mov %r1, 0
    storew %r0, 0x08, %r1           ; Sends command MAP_BUFFER

; 3) Clears screen buffer
    mov %r0, SCREEN_BUFF
    mov %r1, 0x0E200E20             ; Fill with spaces and gray foreground
    mov %r2, TDA_TEXTBUFF_SIZE      ; TDA text buffer size
    call DW_MEMSET

; 4) Sets cursor
    mov %r0, 0
    storew CURSOR_COL, %r0          ; Sets cursor at 0,0
    load %r1, HW_CURSOR_ADDR
    storew %r1, %r0                 ; Sets HW cursor at 0,0

END_INIT_PRIMARY_GRAPH:

; vim: set filetype=asmtr32 :
