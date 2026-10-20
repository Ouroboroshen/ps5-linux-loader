.PHONY: all clean

ifndef PS5_PAYLOAD_SDK
    PS5_PAYLOAD_SDK = /opt/ps5-payload-sdk/
endif

include $(PS5_PAYLOAD_SDK)/toolchain/prospero.mk

BIN := bin/ps5-linux-loader.elf
SRC := $(wildcard source/*.c)
OBJS := $(SRC:.c=.o)

CFLAGS  := -std=c23 -Wall -Iinclude -Ishellcode_hv -Ishellcode_kernel
LDFLAGS :=

SC_0607_H := shellcode_0607/shellcode_0607.h
SC_HV_H := shellcode_hv/shellcode_hv.h
SC_K_H  := shellcode_kernel/shellcode_kernel.h
SC_K_13XX_H := shellcode_kernel_13xx/shellcode_kernel_13xx.h

all: $(SC_0607_H) $(SC_HV_H) $(SC_K_H) $(SC_K_13XX_H) $(BIN)

$(SC_0607_H):
	$(MAKE) -C shellcode_0607

$(SC_HV_H): shellcode_hv/main.c shellcode_hv/utils.c \
		shellcode_hv/boot_linux.c shellcode_hv/boot_linux.h \
		shellcode_hv/shellcode_hv_args.h shellcode_hv/utils.h \
		shellcode_hv/linker.ld shellcode_hv/Makefile \
		include/config.h include/linux.h
	$(MAKE) -C shellcode_hv

$(SC_K_H):
	$(MAKE) -C shellcode_kernel

$(SC_K_13XX_H): $(SC_HV_H) shellcode_kernel/main.c \
		shellcode_kernel/boot_linux.c shellcode_kernel/utils.c \
		shellcode_kernel/main.h shellcode_kernel/boot_linux.h \
		shellcode_kernel/utils.h shellcode_kernel/shellcode_kernel_args.h \
		shellcode_kernel/linker.ld include/config.h include/linux.h \
		shellcode_kernel_13xx/Makefile
	$(MAKE) -C shellcode_kernel_13xx

$(OBJS): %.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

source/prepare_resume.o: $(SC_K_13XX_H)

$(BIN): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

clean:
	rm -f $(BIN) $(OBJS)
	$(MAKE) -C shellcode_0607 clean
	$(MAKE) -C shellcode_hv clean
	$(MAKE) -C shellcode_kernel clean
	$(MAKE) -C shellcode_kernel_13xx clean
