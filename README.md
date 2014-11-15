Trillek firmware v0.1.0
=======================

Firmware for the Trillek computer v0.1.0

## What does / TODO list

- [x] Quick check of RAM
- [x] Get avaliable RAM
- [x] Set Stack
- [x] Generate a table with installed devices
- [ ] Initialize Keyboard and Screen
- [ ] Print boot info on screen
- [ ] Try to bootup from floppy
- [ ] Store/Read config data from NVRAM like bootup device preferences, main keayboard, main monitor, etc...
- [ ] Implement a way to allow the user to setup config data
- [ ] Implement a machine code monitor (Woz monitor clone), that would run if can't find a media were can boot

## RAM variables

The firmware stores some data on the RAM, using the first few KiB of ram for this. The map it's :

 * 0x0000 - 0x03FF : Interrupt vector table : 256 entries of double words
 * 0x0400 : TOP_RAM_ADDR (dw) : Highest valid RAM address, and the size of the RAM
 * 0x07FF : TOTAL_DEVICES (db) : Number of connected devices
 * 0x0800 : PRIMARY_GRPH : Slot of the primary graphics card
 * 0x07FD : PRIMARY_KEYB : Slot of the primary keyboard
 * 0x07FE : DEVICES_TABLE : TOTAL_DEVICES entries of words (see Devices table)


## Devices table

The firmware fills a variable lenght table with info about the plugged devices. The table is sorted by device slot. Each entry consists of :

 * dev_slot (byte) : Slot were is the device
 * dev_type (byte) : Device type, that allow to a more fast search for speficic device types

The max expected size of the table is 256 * 2 = 512 bytes


