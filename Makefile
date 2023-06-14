ASSEMBLER = ca65
ASSEMBLER_FLAGS = -t nes
LINKER = ld65
LINKER_FLAGS = -C unrom.cfg
OUTPUT = battleship.nes

default: $(OUTPUT)

build:
	mkdir -p build

build/title.chr: build asset/title.png
	neschr -i asset/title.png -o build/title.chr

build/ascii.chr: build asset/ascii.gif
	neschr -i asset/ascii.gif -o build/ascii.chr

build/blank.chr: build asset/blank.png
	neschr -i asset/blank.png -o build/blank.chr

build/main.o: src/*.s src/**/*.s build/title.chr build/ascii.chr build/blank.chr
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) src/main.s -o build/main.o

$(OUTPUT): build/main.o
	$(LINKER) $(LINKER_FLAGS) build/main.o -o $(OUTPUT)
	@echo "built $(OUTPUT)"

clean:
	rm -rf build
	rm -f $(OUTPUT)
	@echo "cleaned"