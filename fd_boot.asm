; ------------------------------------------------------------------------------
;
; File : fd_boot.asm
;
; Try to boot from a floppy drive
;
; ------------------------------------------------------------------------------

		loadb %r10, TOTAL_FD						; How many floppy drives there are
		loadb %r7, TOTAL_DEVICES				; Device list size
		mov %r8, 0											; device index
		mov %r9, 0											; fd index
FD_BOOT_FOR:
		ifle %r10, %r9									; for (r9=0, r8=0;
			rjmp FD_BOOT_END							;      r9 < r10 && r8 < Devs ; r10++ )
		ifle %r7, %r8
			rjmp FD_BOOT_END

    loadb %r1, %r8, DEVICES_TABLE

    lls %r2, %r1, 8
    add %r2, %r2, BASE_ENUM_CTROL   ; %r2 points to device registers

		loadb %r3, %r2, 1								; Reads type
    ifneq %r3, DEV_TYPE_MSTORAGE
      rjmp FD_BOOT_FOR_NEXT					; Skips to the next iteration

		loadb %r3, %r2, 2								; Reads subtype
    ifneq %r3, 0x01                 ; If not is a 5.25 Floppy drive
      rjmp FD_BOOT_FOR_NEXT					; Skips to the next iteration

		; Here we check if there is a media on the floppy drive
		mov %r0, 0x0003									; Query media command
		storew %r2, 0x08, %r0

		loadw %r0, %r2, 0x10						; Read status code
		ifeq %r0, 0x0000								; If not media, skips
			rjmp FD_BOOT_FOR_NOMEDIA

		; Read sector 0
		mov %r0, BOOT_SECTOR_ADDR				; Address were to dump the sector
		store %r2, 0x0A, %r0						; Write to B:A register
		mov %r0, 0x0001				          ; Sector 0 (CHS 0:0:1)
		storew %r2, 0x0E, %r0						; Write to C register
		mov %r0, 0x00001								; Read Command
		storew %r2, 0x08, %r0

FD_BOOT_WAIT_READ:
		loadw %r0, %r2, 0x10						; Read status code
		ifeq %r0, 0x0003								; Wait to the end of operation
			rjmp FD_BOOT_WAIT_READ

		load %r0, BOOT_MAGIC_ADDR				; Reads the boot mark
		ifneq %r0, BOOT_MAGICNUMBER			; Compare agains the magic number
			rjmp FD_BOOT_FOR_CANT_BOOT

		; Print that is booting from FDx
    mov %r0, STR_BOOTING
    mov %r1, 30
    call PUTS												; Print text
		mov %r0, %r9
    call PUT_UDEC                   ; Print slot of the floppy drive

		call BOOT_SECTOR_ADDR						;  Boot

FD_BOOT_FOR_CANT_BOOT
		add %r9, %r9, 1

FD_BOOT_FOR_NEXT:
    add %r8, %r8, 1
    rjmp FD_BOOT_FOR									; next %r9

FD_BOOT_FOR_NOMEDIA
		add %r9, %r9, 1
		; Print that there is no media
    mov %r0, STR_NO_MEDIA
    mov %r1, 30
    call PUTS

    rjmp FD_BOOT_FOR_NEXT

FD_BOOT_END:
		; Print that can't boot from media
    mov %r0, STR_NO_BOOT
    mov %r1, 30
    call PUTS												; Print

; vim: set filetype=asmtr32 :
