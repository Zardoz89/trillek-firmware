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
- [ ] Configure interrupt handler ?
  - [ ] Keyboard handler
  - [ ] Floppy driver handler
- [ ] Try to bootup from floppy
- [ ] Store/Read config data from NVRAM like bootup device preferences, main keayboard, main monitor, etc...
- [ ] Implement a way to allow the user to setup config data
- [ ] Implement a machine code monitor (Woz monitor clone), that would run if can't find a bootable media
- [ ] Write some auxiliar functions on the firmware but with public access point to allow be reused by software and OS
  - [x] dw_memset : Fill an memory area with a double word value.
  - [x] Basic putc/puts/put_decimal to screen buffer subrutines

## RAM variables

The firmware stores some data on the RAM, using the first few KiB of ram for this. The map it's :

 * 0x0000 - 0x03FF : Interrupt vector table : 256 entries of double words
 * 0x0400 : TOP_RAM_ADDR (dw) : Highest valid RAM address, and the size of the RAM
 * 0x07FF : TOTAL_DEVICES (db) : Number of connected devices
 * 0x0800 : PRIMARY_GRPH : Slot of the primary graphics card
 * 0x07FD : PRIMARY_KEYB : Slot of the primary keyboard
 * 0x07FE : DEVICES_TABLE : TOTAL_DEVICES entries of words (see Devices table)
 * 0x09FE : CURSOR_COL : Column at were the screen cursor is placed
 * 0x09FF : CURSOR_ROW : Row at were the screen cursor is placed
 * 0x0A00 : SCREEN_BUFF : Text buffer used by graphics card

## Devices table

The firmware fills a variable lenght table with info about the plugged devices. The table is sorted by device slot. Each entry consists of :

 * dev_slot (byte) : Slot were is the device
 * dev_type (byte) : Device type, that allow to a more fast search for speficic device types

The max expected size of the table is 32 * 2 = 64 bytes, but we reserve more space in the case that the specs changes.

## Build it

Actually this firmware uses [Meisaka's WaveAsm](https://github.com/Meisaka/WaveAsm)
You need to copy (or link) **WaveAsm.pl** and **tr3200.isf** to the root of this project and run ```make``` . It will generate  a **firmware.ffi** that is a binary blob ready to be used as ROM for the Trillek computer.



