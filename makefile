ASM := vasmtr3200
RM := rm

SOURCEFILES := ${wildcard *.asm}
OBJECTFILE := firmware.ffi
ASMFLAGS := -dotdir

all: firmware.ffi

$(OBJECTFILE): $(SOURCEFILES)
	$(ASM) firmware.asm $(ASMFLAGS) -Fbin -o $(OBJECTFILE) -L $(OBJECTFILE:.ffi=.lst) 

.PHONY: clean
clean:
	$(RM) -f $(OBJECTFILE)
	$(RM) -f $(OBJECTFILE:.ffi=.lst)

