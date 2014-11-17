; ------------------------------------------------------------------------------
;
; File : graph_init.asm
;
; Initialize the primary graphics card
;
; ------------------------------------------------------------------------------

; 1) Search the first graphic card from the device list and make it primary
; TODO Try to get it from the NVRAM so the user could set it

    MOV %r0, 0xFF                   ; counter
    STOREB PRIMARY_GRAPH , %r0      ; We mark it as there is none
    MOV %r0, 0                      ; counter

SEARCH_GRPH_DOLOOP:
    LOADW %r1, %r0, DEVICES_TABLE
    LRS %r2, %r1, 8                 ; Pick only Dev Type
    IFNEQ %r2, DEV_TYPE_GRPH
      JMP SEARCH_GRPH_WHILE_LOOP    ; Skips to the next iteration

    AND %r1, %r1, 0xFF              ; Pick only Slot
    LLS %r2, %r1, 8
    ADD %r2, %r2, 2                 ; Dev. subtype offset
    LOADB %r2, %r2, BASE_ENUM_CTROL ; Reads subtype
    IFNEQ %r2, 0x1                  ; If not is TDA compatible
      JMP SEARCH_GRPH_WHILE_LOOP    ; Skips to the next iteration

    STOREB PRIMARY_GRAPH , %r1      ; We save the device slot
    JMP INIT_PRIMARY_GRAPH

SEARCH_GRPH_WHILE_LOOP:
    ADD %r0, %r0, 2
    IFL %r0, 64                     ; 32 *2
      JMP SEARCH_GRPH_DOLOOP

;   TODO Beep sequence to indicate that there is no a graphics card
;    LOADB %r0, PRIMARY_GRAPH
;    IFEQ %r0, 0xFF
;      CALL BEEP_NO_GRAPH_CARD

; 2) Initialize the primary graphics card
INIT_PRIMARY_GRAPH:
    LOADB %r0, PRIMARY_GRAPH
    IFEQ %r0, 0xFF                  ; There isn't a card to init
      JMP END_INIT_PRIMARY_GRAPH

    LLS %r0, %r0, 8
    ADD %r0, %r0, BASE_ENUM_CTROL
    MOV %r1, SCREEN_BUFF
    STORE %r0, 0x0A, %r1            ; Sets the text buffer
    MOV %r1, 0
    STOREW %r0, 0x08, %r1           ; Sends command MAP_BUFFER

; 3) Clears screen buffer
    MOV %r0, SCREEN_BUFF
    MOV %r1, 0x0E200E20             ; Fill with spaces and gray foreground
    MOV %r2, 600                    ; TDA text buffer size
    CALL DW_MEMSET

    MOV %r0, 0
    STOREW CURSOR_COL, %r0          ; Sets cursor at 0,0

END_INIT_PRIMARY_GRAPH:


