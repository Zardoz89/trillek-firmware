; ------------------------------------------------------------------------------
;
; File : firmware.asm
; Trillek firmware   v 0.1.0
;
; ------------------------------------------------------------------------------

.include "constants.asm"
.include "ram_vars.asm"

; Firmware entrypoint and initial quickcheck of RAM
.include "init.asm"
    MOV %r0, 0
    STOREB FIRM_INITIATED, %r0

; Code that counts how many devices are, and fills the device table
.include "dev_count.asm"

; Gets primary graphics card and initialize it
.include "graph_init.asm"

; Get the first keyboard as primary
.include "keyb_init.asm"

; Print status to the screen
.include "boot_info.asm"

    MOV %r0, 0xFF
    STOREB FIRM_INITIATED, %r0  ; We are initiated all basic stuff

; TODO Remove this
    JMP CRASH

; Auxiliar subrutines
.include "aux_functions.asm"

; Text buffer subrutines
.include "text_buffer.asm"


CRASH:      ; If something goes very wrong, here is crash point
    SLEEP
    JMP CRASH ; If wakeups, try again to sleep

FIRMWARE_VERSION:
    .db 0   ; Revision
    .db 1   ; Minor
    .db 0   ; Major

STR_RAM_OK:
    .db "RAM OK. Detected ",0
STR_RAM_BYTES:
    .db " KiB",0
STR_DEVICES:
    .db " devices detected",0
STR_GRAPH_CARD_AT:
    .db "  Graphics card at slot : ",0
STR_KEYBOARD_CARD_AT:
    .db "  Keyboard at slot : ",0
STR_FLOPPY_LIST:
    .db "  Floppy drives :",0
STR_FLOPPY_FDX:
    .db " FD",0
