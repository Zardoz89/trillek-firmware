; ------------------------------------------------------------------------------
;
; File : firmware.asm
; Trillek firmware   v 0.1.0
;
; ------------------------------------------------------------------------------

.include "ram_vars.asm"

; Firmware entrypoint and initial quickcheck of RAM
.include "init.asm"

CRASH:      ; If something goes very wrong, here is crash point
  SLEEP
  JMP CRASH ; If wakeups, try again to sleep

FIRMWARE_VERSION:
    .db 0   ; Revision
    .db 1   ; Minor
    .db 0   ; Major
