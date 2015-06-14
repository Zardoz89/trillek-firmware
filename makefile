ASM := vasm-tr3200
LD := vlink
RM := rm

SRCFILES := boot_info.asm cmonitor.asm dev_count.asm fd_boot.asm firmware.asm graph_init.asm init.asm keyb_init.asm ${wildcard *.ainc}
LIBSRCFILEs := aux_functions.asm text_buffer.asm
OUTPUTFILE := firmware.ffi

ASMFLAGS := -dotdir
LDFLAGS := -brawbin1 -Ttext 0x100000

all: firmware.bin

firmware.o: $(SRCFILES) ${wildcard *.ainc}
	$(ASM) firmware.asm $(ASMFLAGS) -Fvobj -o firmware.o -L firmware.lst

aux_functions.o: aux_functions.asm ${wildcard *.ainc}
	$(ASM) aux_functions.asm $(ASMFLAGS) -Fvobj -o aux_functions.o -L aux_functions.lst
text_buffer.o: text_buffer.asm ${wildcard *.ainc}
	$(ASM) text_buffer.asm $(ASMFLAGS) -Fvobj -o text_buffer.o -L text_buffer.lst

firmware.bin: firmware.o text_buffer.o aux_functions.o
	$(LD) firmware.o text_buffer.o aux_functions.o $(LDFLAGS) -o firmware.bin -M > firmware.map

.PHONY: clean
clean:
	$(RM) -f *.o
	$(RM) -f *.lst
	$(RM) -f *.map

