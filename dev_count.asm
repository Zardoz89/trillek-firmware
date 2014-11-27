; ------------------------------------------------------------------------------
;
; File : dev_count.asm
; Counts how many devices are, and fills device list
;
; Uses %r0, %r1, %r2, %r3
;
; ------------------------------------------------------------------------------

HWN_BEGIN:
    MOV %r0, 0                      ; %r0 counts devices
    MOV %r1, 0                      ; %r1 actual slot

HWM_DO_LOOP:
    LLS %r3, %r1, 8                 ; 0xXX00
    LOADB %r2, %r3, BASE_ENUM_CTROL ; Read from 0x11XX00
    IFNEQ %r2, 0xFF									; If there isn't a device ...
      JMP HWM_WHILE_LOOP            ; Skips to the next iteration

    STOREB %r0, DEVICES_TABLE, %r1  ; Puts on the list, the device slot
    ADD %r0, %r0, 1                 ; Increase the count of devices

HWM_WHILE_LOOP:                     ; while (++i < 32)
    ADD %r1, %r1, 1
    IFL %r1, 32
      JMP HWM_DO_LOOP

    STOREB TOTAL_DEVICES, %r0       ; Stores the total number of devices

