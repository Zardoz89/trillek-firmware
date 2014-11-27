ASM := ./WaveAsm.pl
RM := rm

SOURCEFILES := ${wildcard *.asm}
OBJECTFILE := firmware.ffi
ASMFLAGS :=


all: firmware.ffi

$(OBJECTFILE): $(SOURCEFILES)
	$(ASM) firmware.asm $(ASMFLAGS)

.PHONY: clean
clean:
	$(RM) -f $(OBJECTFILE)

