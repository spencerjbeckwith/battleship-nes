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
            sei
            cld
            ldx #$40
            stx $4017 ; Disable IRQ
            ldx #$ff
            txs
            inx
            stx $2000 ; Disable vblank
            stx $2001 ; Disable rendering
            stx $4010 ; Disable DMC IRQs

            : ; Wait for a vblank
                bit $2002
                bpl :-
        
            : ; Wipe RAM
                lda #$00
                sta $0000, x
                sta $0100, x
                sta $0300, x
                sta $0400, x
                sta $0500, x
                sta $0600, x
                sta $0700, x

                lda #$ff
                sta $0200, x ; Put $ff into OAM instead of $00

                inx
                bne :-

            : ; Wait for another vblank
                bit $2002
                bpl :-

            ; Switch to first bank
            ldy #$00
            jsr Bankswitch

            ; Load CHR-RAM
            ; TODO

            ; Load palettes
            ; TODO

            ; Initialize music
            ; TODO

            ; Initialize nametables
            ; TODO

            ; Initialize attributes
            ; TODO

            ; Reset scroll
            bit $2002
            lda #$00
            sta $2005
            sta $2005

            ; Initialize game state
            ; TODO

            ; Enable vblank, PPU w/ right table as background, and 8x16 sprites
            lda #%10010000
            sta $00 ; TODO set this up as PPUCTRL in zeropage
            sta $2000
            lda #%00011110
            sta $2001

            ; Infinite loop, for now
            :
                jmp :-

        NMI:
            ; Push all registers to the stack
            pha
            txa
            pha
            tya
            pha

            ; TODO time-sensitive NMI stuff

            ; Put current bank on the stack
            lda $01 ; replace me from ZP
            pha

            ; Sound/music step

            ; Return to old bank
            pla
            tay
            jsr Bankswitch

            ; Pull registers off the stack and return
            pla
            tay
            pla
            tax
            pla
            rti

        Bankswitch:
            sty $01 ; TODO set this up as current bank in ZP
            lda Banktable, y
            sta Banktable, y
            rts

            Banktable:
                .byte $00, $01, $02, $03, $04, $05, $06

    .endscope

.segment "VECTORS"
    .word Main::NMI
    .word Main::Initialization
    .byte $00, $00 ; No IRQ

.segment "ZEROPAGE"
    ; ...

.segment "RAM"
    ; ...