# Define variables
AS=nasm                  # Assembler command (nasm)
ASFLAGS=-f bin           # Assemble to flat binary format
OUTPUT=bin/boot.bin     # Final output bootloader binary
STAGE1=src/stage1_boot.asm
STAGE2=src/stage2_boot.asm
STAGE1_BIN=src/stage1_boot.bin
STAGE2_BIN=src/stage2_boot.bin
QEMU=qemu-system-x86_64   # QEMU emulator for running the bootloader
QEMUFLAGS=-drive format=raw,file=$(OUTPUT) # QEMU flags to load the raw binary

# Default target
all: $(OUTPUT)

# Rule to assemble both stages
$(STAGE1_BIN): $(STAGE1)
	$(AS) $(ASFLAGS) -o $(STAGE1_BIN) $(STAGE1)

$(STAGE2_BIN): $(STAGE2)
	$(AS) $(ASFLAGS) -o $(STAGE2_BIN) $(STAGE2)

# Concatenate the two stages into the final bootloader binary
$(OUTPUT): $(STAGE1_BIN) $(STAGE2_BIN)
	@mkdir -p bin  # Ensure the output directory exists
	cat $(STAGE1_BIN) $(STAGE2_BIN) > $(OUTPUT)
	rm -f $(STAGE1_BIN) $(STAGE2_BIN)  # Delete the intermediate bin files

# Rule to run QEMU with the bootloader
run: $(OUTPUT)
	$(QEMU) $(QEMUFLAGS)

# Clean up generated files
clean:
	rm -f $(OUTPUT) $(STAGE1_BIN) $(STAGE2_BIN)

# Phony targets (not actual files)
.PHONY: all run clean
