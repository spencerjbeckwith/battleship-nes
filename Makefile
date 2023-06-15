# `make` - build ROM
# `make clean` - cleanup build
# If `make` is failing, change these params to the appropriate programs on your system

NESCHR = neschr
FAMISTUDIO = famistudio
ASSEMBLER = ca65
ASSEMBLER_FLAGS = -t nes
LINKER = ld65
LINKER_FLAGS = -C unrom.cfg
OUTPUT = battleship.nes

default: $(OUTPUT)

build:
	mkdir -p build

build/title.chr: build asset/title.png
	$(NESCHR) -i asset/title.png -o build/title.chr

build/ascii.chr: build asset/ascii.gif
	$(NESCHR) -i asset/ascii.gif -o build/ascii.chr

build/blank.chr: build asset/blank.png
	$(NESCHR) -i asset/blank.png -o build/blank.chr

build/sfx.s: build asset/sfx.fms
	$(FAMISTUDIO) asset/sfx.fms famistudio-asm-sfx-export build/sfx.s -famistudio-asm-format:ca65

build/main.o: src/*.s src/**/*.s build/title.chr build/ascii.chr build/blank.chr build/sfx.s
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) src/main.s -o build/main.o

$(OUTPUT): build/main.o
	$(LINKER) $(LINKER_FLAGS) build/main.o -o $(OUTPUT)
	@echo "built $(OUTPUT)"

clean:
	rm -rf build
	rm -f $(OUTPUT)
	@echo "cleaned"