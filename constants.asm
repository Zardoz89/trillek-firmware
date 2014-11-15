; ------------------------------------------------------------------------------
;
; File : constants.asm
; Contants related to the Computer architecture
;
; ------------------------------------------------------------------------------

ROM_START         .EQU 0x100000   ; Were begins the ROM
BASE_ENUM_CTROL   .EQU 0x110000   ; Were begins the Hard Enuem&Ctrol regs


; Embed devices addresses ------------------------------------------------------
BEEPER_ADDR       .EQU 0x11E020

RNG_ADDR          .EQU 0x11E040

RTC_SEC_ADDR      .EQU 0x11E030
RTC_MIN_ADDR      .EQU 0x11E031
RTC_HOUR_ADDR     .EQU 0x11E032
RTC_DAY_ADDR      .EQU 0x11E033
RTC_MONTH_ADDR    .EQU 0x11E034
RTC_YEAR_ADDR     .EQU 0x11E035   ; Word size

TMR0_VAL_ADDR     .EQU 0x11E000   ; Double word size
TMR0_RELOAD_ADDR  .EQU 0x11E004   ; Double word size
TMR1_VAL_ADDR     .EQU 0x11E008   ; Double word size
TMR1_RELOAD_ADDR  .EQU 0x11E00C   ; Double word size
TMR_CFG_ADDR      .EQU 0x11E010

; Devices stuff ----------------------------------------------------------------
; Dev types
DEV_TYPE_COMMS    .EQU 0x02       ; Comunication device
DEV_TYPE_HID      .EQU 0x03       ; Human interface device (keyb/joytsticks)
DEV_TYPE_GRPH     .EQU 0x0E       ; Graphics cards
DEV_TYPE_MSTORAGE .EQU 0x08       ; Masive Storage


