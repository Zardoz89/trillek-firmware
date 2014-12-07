Trillek firmware v0.1.0
=======================

Firmware for the Trillek computer v0.1.0

## What does / TODO list

- [x] Quick check of RAM
- [x] Get available RAM
- [x] Set Stack
- [x] Generate a table with installed devices
- [x] Initialize Screen
  - [x] Gets a primary screen as the device with lowest slot
  - [x] Config it
  - [x] Clear screen
- [X] Print boot info on screen
  - [X] Total RAM detected
  - [X] Primary graphic card being used
  - [X] Primary keyboard being used
  - [X] Floppy drives detected
- [X] Try to boot-up from floppy
- [ ] Store/Read config data from NVRAM like boot-up device preferences, main keyboard, main monitor, etc...
- [ ] Implement a way to allow the user to setup config data
- [x] Implement a machine code monitor (Woz monitor clone), that would run if can't find a bootable media
  - [x] Examine value at address
  - [x] Examine a range of addresses
  - [x] Write data to RAM
  - [X] Run code at an address (CALL address)
  - [ ] Use of arrows to manipulate input buffer
- [ ] Write some auxiliary functions on the firmware but with public access point to allow be reused by software and OS
  - [x] dw_memset : Fill an memory area with a double word value.
  - [x] Basic putc/puts/put_decimal/put_uhex to screen buffer subrutines
    - PUTC : Write a character. \n Jumps to the next line
    - PUTS : Write a ASCIIz string
    - PUT_UDEC : Write a decimal value
    - PUT_UHEX : Write a double word value on hexadecimal
    - PUT_UWHEX : Write a word value on hexadecimal
    - PUT_UBHEX : Write a byte value on hexadecimal

## RAM variables

The firmware stores some data on the RAM, using the first few KiB of ram for this. The map it's :

 * 0x0000 - 0x03FF : Interrupt vector table : 256 entries of double words
 * 0x0400 : TOP_RAM_ADDR : Double word. Highest valid RAM address, and the size of the RAM
 * 0x0404 : FIRM_INITIATED : Byte. Set to 0xFF if the firmware as finalized to initiated all basic stuff
 * 0x0408 : CURSOR_COL : Byte. Column at were the screen cursor is placed
 * 0x0409 : CURSOR_ROW : Byte. Row at were the screen cursor is placed
 * 0x040C : HW_CURSOR_ADDR : Double word. Address of Hardware cursor position. Use to control the HW cursor on screen
 * 0x04FC : TOTAL_FD : Byte. How many floppy drives there are.
 * 0x04FD : PRIMARY_KEYB : Byte. Slot were is the primary keyboard.
 * 0x04FE : PRIMARY_GRAPH : Byte. Slot were is the primary graphics card.
 * 0x04FF : TOTAL_DEVICES : Byte. Number of devices.
 * 0x0500 : DEVICES_TABLE : Device lists were each entry is a byte witdh, that indicates a slot with a device. Max size = 32 bytes, but we reserve 220 bytes -> 0x500 to 0x5DC
 * 0x0600 - 0xF60 : SCREEN_BUFF : Were begins the screen buffer used by the firmware, ends at 0x0F60

## Devices list

The firmware fills a variable length list that contains the slots with a device
plugged on it. The table is sorted by device slot. Each entry takes a byte.
The max expected size of the table is 32 entries (32 bytes), but we reserve more
space in the case that the specs changes, that is for 220 entries (220 bytes).

## Floppy drives

Each floppy drive, begging to count from the lowest slot, gets a name like FDx.
So, the first floppy drive is FD0, the second is FD1, etc...

### Bootable floppies

The boot-up sequence is :

1. See if the floppy drive have a floppy, if not, try with the next floppy drive.
2. If there is a floppy, reads the first sector and dumps to the address 0x001400
3. If the the four last bytes of the sector have the signature 0x30, 0x33, 0x52, 0x54 ("TR32"), assumes that is a bootable media and jumps to the address 0x001400.
4. If not is a bootable floppy, try with the next floppy drive.
5. If there isn't any bootable floppy, then launched the machine code monitor.

When the firmware calls the boot code placed on address 0x001400, %r9 is set to
number of floppy drive from was read the boot sector.

## Machine Code Monitor

The monitor is a clone of Wozniak's code monitor of Apple I and ]\[ . With it is possible to examine RAM values on the fly and input values to the RAM, so could be used like a primitive debugger and as a crude and primitive way of doing low level programming typing machine code. Also, can *Run* code on RAM, doing a CALL to an address. More information about Woz's original machine code monitor [here](http://www.sbprojects.com/projects/apple1/wozmon.php)

## Build it

Actually this firmware uses [Meisaka's WaveAsm](https://github.com/Meisaka/WaveAsm)
You need to copy (or link) **WaveAsm.pl** and **tr3200.isf** to the root of this project and run ```make``` . It will generate  a **firmware.ffi** that is a binary blob ready to be used as ROM for the Trillek computer.



