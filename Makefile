BOOTLOADER_SRC := $(wildcard src/*.asm)
BOOTLOADER_OBJ := $(patsubst %.asm, %.o, $(BOOTLOADER_SRC))
OUTDIR = build
VERSION = 0_0_0
DEBUG = 0

.PHONY: all
all: clean spark kernel bootdisk

%.o: %.asm
ifeq ($(DEBUG),1)
	nasm -f elf64 $< -F dwarf -g -o $(subst src/, $(OUTDIR)/, $@)
	# TODO: org 0x7c00 instruction not works for elf64 format `-Ttext=0x7c00` is enough ???
	ld -Ttext=0x7c00 -m elf_x86_64 -T src/main.lds $(subst src/, $(OUTDIR)/, $@) -o $(subst src/, $(OUTDIR)/, $@.elf)
	# FIXME(error): objcopy: build/spark.o: invalid bfd target
	# objcopy -O build/spark $(OUTDIR)/spark.o.elf $(OUTDIR)/spark.o
else
	nasm -f bin $< -o $(subst src/, $(OUTDIR)/, $@)
endif

.PHONY: spark
spark:
	nasm -f bin src/spark.asm -o $(OUTDIR)/spark.o

.PHONY: kernel
kernel:
	nasm -f bin src/kernel.asm -o $(OUTDIR)/kernel.o

.PHONY: bootdisk
bootdisk: $(BOOTLOADER_OBJ)
	dd if=/dev/zero of=$(OUTDIR)/disk_$(VERSION).img bs=512 count=2880
	# put spark on the 1st sector
	dd conv=notrunc if=$(OUTDIR)/spark.o of=$(OUTDIR)/disk_$(VERSION).img bs=512 count=1 seek=0
	# put kernel on the 2nd sector
	dd conv=notrunc if=$(OUTDIR)/kernel.o of=$(OUTDIR)/disk_$(VERSION).img bs=512 count=1 seek=1

.PHONY: qemu
qemu:
	# Ctrl+G to get out the mouse on qemu
	qemu-system-i386 -machine q35 -fda $(OUTDIR)/disk_$(VERSION).img -gdb tcp::26000 -S

.PHONY: clean
clean:
	rm -rf build/*
