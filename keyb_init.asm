; ------------------------------------------------------------------------------
;
; File : keyb_init.asm
;
; Initialize the primary keyboard
;
; ------------------------------------------------------------------------------

; 1) Search the first graphic card from the device list and make it primary
; TODO Try to get it from the NVRAM so the user could set it

    mov %r0, 0xFF
    storeb PRIMARY_KEYB , %r0       ; We mark it as there is none
    mov %r0, 0                      ; counter
		loadb %r10, TOTAL_DEVICES				; How many items ?

SEARCH_KEYB_DOLOOP:
		loadb %r1, %r0, DEVICES_TABLE

    lls %r2, %r1, 8
    add %r2, %r2, BASE_ENUM_CTROL   ; %r2 points to device registers

		loadb %r3, %r2, 1								; Reads type
    ifneq %r3, DEV_TYPE_HID
      jmp SEARCH_KEYB_WHILE_LOOP    ; Skips to the next iteration

		loadb %r3, %r2, 2								; Reads subtype
    ifneq %r3, 0x01                 ; If not is an Western/Latin Keyboard
      jmp SEARCH_KEYB_WHILE_LOOP    ; Skips to the next iteration

    storeb PRIMARY_KEYB, %r1				; We save the device slot
    jmp INIT_PRIMARY_KEYB

SEARCH_KEYB_WHILE_LOOP:
    add %r0, %r0, 2
    ifl %r0, %r10                   ; while (%r0 < $r10)
      jmp SEARCH_KEYB_DOLOOP

;   TODO Beep sequence to indicate that there is no a graphics card
;    LOADB %r0, PRIMARY_KEYB
;    IFEQ %r0, 0xFF
;      CALL BEEP_NO_KEYB_CARD

; 2) Initialize the primary keyboard (not need at this moment)
INIT_PRIMARY_KEYB:

; vim: set filetype=asmtr32 :
