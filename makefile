ASM := vasm-tr3200
RM := rm

SOURCEFILES := ${wildcard *.asm} ${wildcard *.ainc}
OBJECTFILE := firmware.ffi
ASMFLAGS := -dotdir

all: firmware.ffi

$(OBJECTFILE): $(SOURCEFILES)
	$(ASM) firmware.asm $(ASMFLAGS) -Fbin -o $(OBJECTFILE) -L $(OBJECTFILE:.ffi=.lst) 

.PHONY: clean
clean:
	$(RM) -f $(OBJECTFILE)
	$(RM) -f $(OBJECTFILE:.ffi=.lst)

