; ------------------------------------------------------------------------------
;
; File : firmware.asm
; Trillek firmware   v 0.2.0
;
; ------------------------------------------------------------------------------

    .org 0x100000             ; ROM begins at 0x100000
    .include "constants.ainc"
    .include "ram_vars.ainc"

    .org 0x100000             ; ROM begins at 0x100000
; Firmware entrypoint and initial quickcheck of RAM
    .include "init.asm"
    mov %r0, 0
    storeb FIRM_INITIATED, %r0

; Code that counts how many devices are, and fills the device table
    .include "dev_count.asm"

; Gets primary graphics card and initialize it
    .include "graph_init.asm"

; Get the first keyboard as primary
    .include "keyb_init.asm"

; Print status to the screen
    .include "boot_info.asm"

    mov %r0, 0xFF
    storeb FIRM_INITIATED, %r0  ; We are initiated all basic stuff

; Try to boot from floppy drives
    .include "fd_boot.asm"

; Fallback to the machine code monitor
    .include "cmonitor.asm"

; Never should reach this
CRASH:        ; If something goes very wrong, here is crash point
    sleep
    jmp CRASH ; If wakeups, try again to sleep

; Auxiliar subrutines
    .include "aux_functions.asm"

; Text buffer subrutines
    .include "text_buffer.asm"

    .struct version_struct
rev     .db 0   ; Revision
minor   .db 2   ; Minor
major   .db 0   ; Major
    .endstruct
FIRMWARE_VERSION version_struct

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
STR_NO_BOOT:
    .db "Can't boot on any floppy drive",0
STR_NO_MEDIA:
    .db "Floppy drive not have a floppy",0
STR_BOOTING:
    .db "Trying to boot from FD",0

; vim: set filetype=asmtr32 :
