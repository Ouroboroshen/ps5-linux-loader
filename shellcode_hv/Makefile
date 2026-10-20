ifeq ($(shell uname -m),aarch64)
CC      = x86_64-linux-gnu-gcc
LD      = x86_64-linux-gnu-ld
OBJCOPY = x86_64-linux-gnu-objcopy
else
CC      = gcc
LD      = ld
OBJCOPY = objcopy
endif
CFLAGS  = -O2 -fno-stack-protector -ffreestanding -nostdlib -fcf-protection=none -mno-sse -mno-sse2 -m64
LDFLAGS = -T linker.ld
TARGET  = shellcode_hv.elf
TEXT_BIN = shellcode_hv.bin
dump = shellcode_hv.h

SRC = main.c utils.c boot_linux.c
OBJ = $(SRC:.c=.o)
HEADERS = boot_linux.h shellcode_hv_args.h utils.h ../include/config.h \
	../include/linux.h

all: $(dump)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJ) -o $(TARGET)

$(OBJ): %.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(TEXT_BIN): $(TARGET)
	$(OBJCOPY) -O binary -j .shell_code $(TARGET) $(TEXT_BIN)

clean:
	rm -f $(OBJ) $(TARGET) $(TEXT_BIN) $(dump)

$(dump): $(TEXT_BIN)
	xxd -i $(TEXT_BIN) > $(dump)
