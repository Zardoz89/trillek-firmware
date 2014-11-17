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

    MOV %r0, 0xFF
    STOREB FIRM_INITIATED, %r0  ; We are initiated all basic stuff

    MOV %r0, STR_RAM_OK
    MOV %r1, 18
    CALL PUTS

    LOAD %r0, TOP_RAM_ADDR
    LRS %r0, %r0, 10            ; Divide by 1024
    CALL PUT_UDEC

    MOV %r0, STR_RAM_BYTES
    MOV %r1, 4
    CALL PUTS


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
