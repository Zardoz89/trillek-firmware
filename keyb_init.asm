; ------------------------------------------------------------------------------
;
; File : keyb_init.asm
;
; Initialize the primary keyboard
;
; ------------------------------------------------------------------------------

; 1) Search the first graphic card from the device list and make it primary
; TODO Try to get it from the NVRAM so the user could set it

    MOV %r0, 0xFF                   ; counter
    STOREB PRIMARY_KEYB , %r0      ; We mark it as there is none
    MOV %r0, 0                      ; counter

SEARCH_KEYB_DOLOOP:
    LOADW %r1, %r0, DEVICES_TABLE
    LRS %r2, %r1, 8                 ; Pick only Dev Type
    IFNEQ %r2, DEV_TYPE_HID
      JMP SEARCH_KEYB_WHILE_LOOP    ; Skips to the next iteration

    AND %r1, %r1, 0xFF              ; Pick only Slot
    LLS %r2, %r1, 8
    ADD %r2, %r2, 2                 ; Dev. subtype offset
    LOADB %r2, %r2, BASE_ENUM_CTROL ; Reads subtype
    IFNEQ %r2, 0x01                 ; If not is an Western/Latin Keyboard
      JMP SEARCH_GRPH_WHILE_LOOP    ; Skips to the next iteration

    STOREB PRIMARY_KEYB , %r1      ; We save the device slot
    JMP INIT_PRIMARY_KEYB

SEARCH_KEYB_WHILE_LOOP:
    ADD %r0, %r0, 2
    IFL %r0, 64                     ; 32 *2
      JMP SEARCH_KEYB_DOLOOP

;   TODO Beep sequence to indicate that there is no a graphics card
;    LOADB %r0, PRIMARY_KEYB
;    IFEQ %r0, 0xFF
;      CALL BEEP_NO_KEYB_CARD

; 2) Initialize the primary keyboard (not need at this moment)
INIT_PRIMARY_KEYB:

