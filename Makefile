BOOTLOADER_SRC := $(wildcard src/*.asm)
BOOTLOADER_OBJ := $(patsubst %.asm, %.o, $(BOOTLOADER_SRC))
OUTDIR = build
VERSION = 0_0_0

all: spark bootdisk

%.o: %.asm
	nasm -f bin $< -o $(subst src/, build/, $@)

spark:
	nasm -f bin src/spark.asm -o $(OUTDIR)/spark.o

kernel:
	nasm -f bin src/kernel.asm -o $(OUTDIR)/kernel.o

bootdisk: $(BOOTLOADER_OBJ)
	dd if=/dev/zero of=$(OUTDIR)/disk_$(VERSION).img bs=512 count=2880
	# put spark on the 1st sector
	dd conv=notrunc if=$(OUTDIR)/spark.o of=$(OUTDIR)/disk_$(VERSION).img bs=512 count=1 seek=0
	# put kernel on the 2nd sector
	dd conv=notrunc if=$(OUTDIR)/kernel.o of=$(OUTDIR)/disk_$(VERSION).img bs=512 count=1 seek=1
