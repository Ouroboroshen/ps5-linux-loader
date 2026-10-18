ifeq ($(shell uname -m),aarch64)
CC      = x86_64-linux-gnu-gcc
LD      = x86_64-linux-gnu-ld
OBJCOPY = x86_64-linux-gnu-objcopy
else
CC      = gcc
LD      = ld
OBJCOPY = objcopy
endif
CFLAGS  = -Os -fno-stack-protector -ffreestanding -nostdlib \
	-fcf-protection=none -mno-sse -mno-sse2 -m64 -ffunction-sections \
	-fdata-sections -DFW_13XX_PORT=1
LDFLAGS = -T ../shellcode_kernel/linker.ld \
	-Wl,--gc-sections,--defsym,SHELLCODE_LIMIT=0x3910
TARGET  = shellcode_kernel_13xx.elf
TEXT_BIN = shellcode_kernel_13xx.bin
dump = shellcode_kernel_13xx.h

SRC = main.c boot_linux.c utils.c
OBJ = $(SRC:.c=.o)
HEADERS = ../shellcode_kernel/main.h ../shellcode_kernel/boot_linux.h \
	../shellcode_kernel/utils.h ../shellcode_kernel/shellcode_kernel_args.h \
	../include/config.h ../include/linux.h ../shellcode_hv/shellcode_hv.h

all: $(dump)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJ) -o $(TARGET)

$(OBJ): %.o: ../shellcode_kernel/%.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(TEXT_BIN): $(TARGET)
	$(OBJCOPY) -O binary -j .shell_code $(TARGET) $(TEXT_BIN)

clean:
	rm -f $(OBJ) $(TARGET) $(TEXT_BIN) $(dump)

$(dump): $(TEXT_BIN)
	xxd -i $(TEXT_BIN) > $(dump)

.PHONY: all clean
