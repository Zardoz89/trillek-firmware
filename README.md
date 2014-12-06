Trillek firmware v0.1.0
=======================

Firmware for the Trillek computer v0.1.0

## What does / TODO list

- [x] Quick check of RAM
- [x] Get avaliable RAM
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
- [X] Try to bootup from floppy (broken)
- [ ] Store/Read config data from NVRAM like bootup device preferences, main keayboard, main monitor, etc...
- [ ] Implement a way to allow the user to setup config data
- [ ] Implement a machine code monitor (Woz monitor clone), that would run if can't find a bootable media
  - [x] Examine value at address
  - [x] Examine a range of addresses
  - [ ] Write data to RAM
  - [X] Run code at an address (CALL address)
  - [ ] Use of arrows to manipulate input buffer
- [ ] Write some auxiliar functions on the firmware but with public access point to allow be reused by software and OS
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
 * 0x0400 : TOP_RAM_ADDR (dw) : Highest valid RAM address, and the size of the RAM
 * 0x04FF : TOTAL_DEVICES (b) : Number of connected devices
 * 0x04FC : TOTAL_FD (b) : Number of floppy drives
 * 0x04FE : PRIMARY_GRAPH (b) : Slot of the primary graphics card
 * 0x04FD : PRIMARY_KEYB (b) : Slot of the primary keyboard
 * 0x0500 : DEVICES_TABLE : TOTAL_DEVICES entries of bytes (see Devices list)
 * 0x0408 : CURSOR_COL (b) : Column at were the screen cursor is placed
 * 0x0409 : CURSOR_ROW (b) : Row at were the screen cursor is placed
 * 0x0600 : SCREEN_BUFF : Text buffer used by graphics card

## Devices list

The firmware fills a variable lenght list that contains the slots with a device
plugged on it. The table is sorted by device slot. Each entry takes a byte.
The max expected size of the table is 32 entries (32 bytes), but we reserve more
space in the case that the specs changes, that is for 220 entries (220 bytes).

## Floppy drives

Each floppy drive, beging to count from the lowest slot, gets a name like FDx.
So, the first floppy drive is FD0, the second is FD1, etc...

### Bootable floppies

The bootup sequence is :

1. See if the floppy drive have a floppy, if not, try with the next floppy drive.
2. If there is a floppy, reads the first sector and dumps to the adress 0x001400
3. If the the four last bytes of the sector have the signature 0x30, 0x33, 0x52, 0x54 ("TR32"), assumes that is a bootable media and jumps to the address 0x001400.
4. If not is a bootable floppy, try with the next floppy drive.
5. If there isn't any bootable floppy, then launched the machine code monitor.

When the firmware calls the boot code placed on address 0x001400, %r9 is set to
number of floppy drive from was read the boot sector.

## Machine Code Monitor

The monitor is a clone of Wozniak's code monitor of Apple I and ]\[ . With it is posible to examine RAM values on the fly and input values to the RAM, so could be used like a primitive debugger and as a crude and primitive way of doing low level programing typing machine code. Also, can *Run* code on RAM, doing a CALL to an address. More information about Woz's original machine code monitor [here](http://www.sbprojects.com/projects/apple1/wozmon.php)

## Build it

Actually this firmware uses [Meisaka's WaveAsm](https://github.com/Meisaka/WaveAsm)
You need to copy (or link) **WaveAsm.pl** and **tr3200.isf** to the root of this project and run ```make``` . It will generate  a **firmware.ffi** that is a binary blob ready to be used as ROM for the Trillek computer.



