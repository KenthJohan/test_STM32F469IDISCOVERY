TARGET = main

# Define the linker script location and chip architecture.
LD_SCRIPT = STM32F469I.ld
MCU_SPEC  = cortex-m4

# Toolchain definitions (ARM bare metal defaults)
TOOLCHAIN = "C:/Program Files (x86)/GNU Tools ARM Embedded/8 2018-q4-major"
CC = $(TOOLCHAIN)/bin/arm-none-eabi-gcc
AS = $(TOOLCHAIN)/bin/arm-none-eabi-as
LD = $(TOOLCHAIN)/bin/arm-none-eabi-ld
OC = $(TOOLCHAIN)/bin/arm-none-eabi-objcopy
OD = $(TOOLCHAIN)/bin/arm-none-eabi-objdump
OS = $(TOOLCHAIN)/bin/arm-none-eabi-size

# Assembly directives.
ASFLAGS += -c
ASFLAGS += -O0
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -Wall
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0

# C compilation directives
CFLAGS += -mcpu=$(MCU_SPEC)
CFLAGS += -mthumb
CFLAGS += -Wall
CFLAGS += -g
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# (Set system to ignore semihosted junk)
CFLAGS += --specs=nosys.specs
CFLAGS += -DSTM32F469xx

# Linker directives.
LSCRIPT = ./$(LD_SCRIPT)
LFLAGS += -mcpu=$(MCU_SPEC)
LFLAGS += -mthumb
LFLAGS += -Wall
LFLAGS += -g
LFLAGS += --specs=nosys.specs
LFLAGS += -nostdlib
LFLAGS += -lgcc
LFLAGS += -T$(LSCRIPT)

INCLUDE = -Ibsp/include/platform/cortex-m/CMSIS
INCLUDE += -Ibsp/include/platform/hal/mcu/stm32f4cube
INCLUDE += -Ibsp/include/platform/hal/mcu/stm32f4cube/STM32F4xx_HAL_Driver
INCLUDE += -Ibsp/include/platform/hal/mcu/stm32f4cube/CMSIS
INCLUDE += -Ibsp/include/
INCLUDE += -Ibsp/include/bsp
INCLUDE += -Ibsp/source/vendor/STM32469I-Discovery

#AS_SRC   =  ./core.S
#AS_SRC   += ./vector_table.S
C_SRC    =  ./isr.c
C_SRC    +=  ./main.c
C_SRC    +=  ./bsp/source/platform/hal/mcu/stm32f4cube/CMSIS/system_stm32f4xx.c

OBJS  = $(AS_SRC:.S=.o)
OBJS += $(C_SRC:.c=.o)

.PHONY: all
all: $(TARGET).bin

%.o: %.S
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OC) -S -O binary $< $@
	$(OS) $<

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f $(TARGET).elf
	rm -f $(TARGET).bin

debug:
	arm-none-eabi-gdb main.elf -ex 'target extended-remote :3333' -ex 'load' -ex 'set disassemble-next-line on' -ex 'show disassemble-next-line' -ex 'frame'
	
	
	
	
	
	