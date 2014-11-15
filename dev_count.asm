; ------------------------------------------------------------------------------
;
; File : dev_count.asm
; Counts how many devices are, and fills devices table
;
; Uses %r0, %r1, %r2, %r3
;
; ------------------------------------------------------------------------------

HWN_BEGIN:
    MOV %r0, 0                      ; %r0 counts devices
    MOV %r1, 0                      ; %r1 actual slot

HWM_DO_LOOP:
    LLS %r3, %r1, 8                 ; 0xXX00
    LOADW %r2, %r3, BASE_ENUM_CTROL ; Read from 0x11XX00
    IFCLEAR %r2, 0x00FF             ; If there isn't a device ...
      JMP HWM_WHILE_LOOP            ; Skips to the next iteration

    ADD %r0, %r0, 1                 ; Increase the count of devices
    AND %r2, %r2, 0xFF00            ; Cleats present mark
    OR  %r2, %r2, %r1               ; Puts device slot
    LLS %r3, %r1, 1                 ; We write words. So we do x2
    STOREW %r3, DEVICES_TABLE, %r2  ; Puts on table the device slot

HWM_WHILE_LOOP:                     ; while (++i < 32)
    ADD %r1, %r1, 1
    IFL %r1, 32
      JMP HWM_DO_LOOP

    STOREB TOTAL_DEVICES, %r0       ; Stores the total number of devices

