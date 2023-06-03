.segment "HEADER"
    .byte "NES", $1a
    .byte $08, $00      ; 4/5: PRG-ROM size, no CHR-ROM
    .byte %00100001     ; 6: Mapper 2 (UNROM), vertical mirroring
    .byte %00001000     ; 7: iNES 2.0 format
    .byte $00, $00, $00 ; No submapper, PRG-ROM > 4MB, or RPG-RAM
    .byte $07           ; 8k CHR-RAM, no battery
    .byte $00, $00      ; NTSC, no special PPU

.include "banks/bank0.s"
.include "banks/bank1.s"
.include "banks/bank2.s"
.include "banks/bank3.s"
.include "banks/bank4.s"
.include "banks/bank5.s"
.include "banks/bank6.s"

.segment "RODATA"
    .scope Main

        Initialization:
            nop ; TODO

        NMI:
            nop ; TODO

    .endscope

.segment "VECTORS"
    .word Main::NMI
    .word Main::Initialization
    .byte $00, $00 ; No IRQ

.segment "ZEROPAGE"
    ; ...

.segment "RAM"
    ; ...