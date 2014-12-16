; ------------------------------------------------------------------------------
;
; File : dev_count.asm
; Counts how many devices are, and fills device list
;
; Uses %r0, %r1, %r2, %r3
;
; ------------------------------------------------------------------------------

HWN_BEGIN:
    mov %r0, 0                      ; %r0 counts devices
    mov %r1, 0                      ; %r1 actual slot

HWM_DO_LOOP:
    lls %r3, %r1, 8                 ; 0xXX00
    loadb %r2, %r3, BASE_ENUM_CTROL ; Read from 0x11XX00
    ifneq %r2, 0xFF									; If there isn't a device ...
      jmp HWM_WHILE_LOOP            ; Skips to the next iteration

    storeb %r0, DEVICES_TABLE, %r1  ; Puts on the list, the device slot
    add %r0, %r0, 1                 ; Increase the count of devices

HWM_WHILE_LOOP:                     ; while (++i < 32)
    add %r1, %r1, 1
    ifl %r1, 32
      jmp HWM_DO_LOOP

    storeb TOTAL_DEVICES, %r0       ; Stores the total number of devices

