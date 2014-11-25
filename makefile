ASM := ./WaveAsm.pl
RM := rm

SOURCEFILES = firmware.asm aux_functions.asm  constants.asm  dev_count.asm  graph_init.asm boot_info.asm  init.asm  ram_vars.asm  text_buffer.asm

ASMFLAGS =


all: firmware.ffi

firmware.ffi: $(SOURCEFILES)
	$(ASM) firmware.asm $(ASMFLAGS)

.PHONY: clean
clean:
	$(RM) -f firmware.ffi

