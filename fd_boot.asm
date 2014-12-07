; ------------------------------------------------------------------------------
;
; File : fd_boot.asm
;
; Try to boot from a floppy drive
;
; ------------------------------------------------------------------------------

		LOADB %r10, TOTAL_FD						; How many floppy drives there are
		LOADB %r7, TOTAL_DEVICES				; Device list size
		MOV %r8, 0											; device index
		MOV %r9, 0											; fd index
FD_BOOT_FOR:
		IFLE %r10, %r9									; for (r9=0, r8=0;
			JMP FD_BOOT_END								;      r9 < r10 && r8 < Devs ; r10++ )
		IFLE %r7, %r8
			JMP FD_BOOT_END

    LOADB %r1, %r8, DEVICES_TABLE

    LLS %r2, %r1, 8
    ADD %r2, %r2, BASE_ENUM_CTROL   ; %r2 points to device registers

		LOADB %r3, %r2, 1								; Reads type
    IFNEQ %r3, DEV_TYPE_MSTORAGE
      JMP FD_BOOT_FOR_NEXT					; Skips to the next iteration

		LOADB %r3, %r2, 2								; Reads subtype
    IFNEQ %r3, 0x01                 ; If not is a 5.25 Floppy drive
      JMP FD_BOOT_FOR_NEXT					; Skips to the next iteration

		; Here we check if there is a media on the floppy drive
		MOV %r0, 0x0003									; Query media command
		STOREW %r2, 0x08, %r0

		LOADW %r0, %r2, 0x10						; Read status code
		IFEQ %r0, 0x0000								; If not media, skips
			JMP FD_BOOT_FOR_NOMEDIA

		; Read sector 0
		MOV %r0, BOOT_SECTOR_ADDR				; Address were to dump the sector
		STORE %r2, 0x0A, %r0						; Write to B:A register
		MOV %r0, 0				              ; Sector 0
		STOREW %r2, 0x0E, %r0						; Write to C register
		MOV %r0, 0x00001								; Read Command
		STOREW %r2, 0x08, %r0

FD_BOOT_WAIT_READ:
		LOADW %r0, %r2, 0x10						; Read status code
		IFEQ %r0, 0x0003								; Wait to the end of operation
			JMP FD_BOOT_WAIT_READ

		LOAD %r0, BOOT_MAGIC_ADDR				; Reads the boot mark
		IFNEQ %r0, BOOT_MAGICNUMBER			; Compare agains the magic number
			JMP FD_BOOT_FOR_CANT_BOOT

		; Print that is booting from FDx
    MOV %r0, STR_BOOTING
    MOV %r1, 30
    CALL PUTS												; Print text
		MOV %r0, %r9
    CALL PUT_UDEC                   ; Print slot of the floppy drive

		CALL 0x001400										; Boot

FD_BOOT_FOR_CANT_BOOT
		ADD %r9, %r9, 1

FD_BOOT_FOR_NEXT:
    ADD %r8, %r8, 1
    JMP FD_BOOT_FOR									; next %r9

FD_BOOT_FOR_NOMEDIA
		ADD %r9, %r9, 1
		; Print that there is no media
    MOV %r0, STR_NO_MEDIA
    MOV %r1, 30
    CALL PUTS

    JMP FD_BOOT_FOR_NEXT

FD_BOOT_END:
		; Print that can't boot from media
    MOV %r0, STR_NO_BOOT
    MOV %r1, 30
    CALL PUTS												; Print

