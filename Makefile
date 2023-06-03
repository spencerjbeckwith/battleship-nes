ASSEMBLER = ca65
ASSEMBLER_FLAGS = -t nes
LINKER = ld65
LINKER_FLAGS = -C unrom.cfg
OUTPUT = battleship.nes

default: $(OUTPUT)

build:
	mkdir -p build

build/main.o: build src/*.s src/**/*.s
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) src/main.s -o build/main.o

$(OUTPUT): build/main.o
	$(LINKER) $(LINKER_FLAGS) build/main.o -o $(OUTPUT)
	@echo "built $(OUTPUT)"

clean:
	rm -rf build
	rm -f $(OUTPUT)
	@echo "cleaned"