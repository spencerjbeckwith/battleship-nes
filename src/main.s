.segment "HEADER"
    .byte "NES", $1a
    .byte $08, $00      ; 4/5: PRG-ROM size, no CHR-ROM
    .byte %00100001     ; 6: Mapper 2 (UNROM), vertical mirroring
    .byte %00001000     ; 7: iNES 2.0 format
    .byte $00, $00, $00 ; No submapper, PRG-ROM > 4MB, or RPG-RAM
    .byte $07           ; 8k CHR-RAM, no battery
    .byte $00, $00      ; NTSC, no special PPU

.include "ram.s"

.include "banks/bank0.s"
.include "banks/bank1.s"
.include "banks/bank2.s"
.include "banks/bank3.s"
.include "banks/bank4.s"
.include "banks/bank5.s"
.include "banks/bank6.s"

.rodata
    .scope Main

        Initialization:
            sei
            cld
            ldx #$40
            stx $4017 ; Disable IRQ
            ldx #$ff
            txs
            inx
            stx PPUCTRL ; Disable vblank
            stx PPUMASK ; Disable rendering
            stx $4010 ; Disable DMC IRQs

            : ; Wait for a vblank
                bit PPUSTATUS
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
                bit PPUSTATUS
                bpl :-

            ; Switch to first bank
            ldy #$00
            jsr Bankswitch

            ; Load CHR-RAM
            ; TODO make this a subroutine?
            lda #>Graphics
            sta zp1
            lda #<Graphics
            sta zp0

            bit PPUSTATUS   ; Reset latch
            lda #$00
            sta PPUADDR     ; Set address in PPU to $0000
            sta PPUADDR
            ldx #$20        ; Copy $20 (32) pages
            :
                lda (zp0), y
                sta PPUDATA
                iny
                bne :-

                inc zp1     ; To next page
                dex
                bne :-      ; When zero pages are left, continue on

            ; Load palettes
            ; TODO make this a subroutine?
            bit PPUSTATUS
            lda #$3f
            sta PPUADDR
            stx PPUADDR
            :
                lda Palettes, x
                sta PPUDATA
                inx
                cpx #$20    ; Copy $20 (32) bytes
                bne :-

            ; Initialize music
            ; TODO

            ; Initialize nametables
            ; TODO

            ; Initialize attributes
            ; TODO

            ; Reset scroll
            bit PPUSTATUS
            lda #$00
            sta PPUSCROLL
            sta PPUSCROLL

            ; Begin OAM after sprite 0
            lda #$04
            sta oam_position

            ; Initialize game state
            ; TODO

            ; Enable vblank, PPU w/ right table as background, and 8x16 sprites
            lda #%10010000
            sta RAM_PPUCTRL
            sta PPUCTRL
            lda #%00011110
            sta PPUMASK

        Logic:
            ; Infinite loop, for now
            inc vblank_waiting
            :
                lda vblank_waiting
                bne :-

            ; TODO frame logic goes here

            jmp Logic

        NMI:
            ; Push all registers to the stack
            pha
            txa
            pha
            tya
            pha

            ; OAMDMA
            lda #$00
            sta OAMADDR
            lda #$02
            sta OAMDMA

            ; Read updates from the PPU buffer
            ; Every PPU buffer entry is at least five bytes and takes the following format:
            ; (PPU address high, PPU address low, flags, length, data byte, [data byte...])
            ; Flags byte format:
            ; 7 6 5 4 3 2 1 0
            ; | | | | | | | +-- repeat. If 1, the first and only data byte will be written (length) times instead of writing (length) bytes from the buffer
            ; | | | | | | +---- unused
            ; | | | | | +------ vertical placement property. If 1, writes occur vertically in the PPU (increment by a $20 instead of $01)
            lda ppu_buffer_addr
            beq @skip_buffer    ; Skip buffer if first entry is 0, meaning no changes were made
                ldx #$00        ; X will track position in the buffer
                @parse_buffer:

                    ; Reset latch and set our target address in the PPU
                    bit PPUSTATUS
                    lda ppu_buffer_addr, x
                    sta PPUADDR
                    lda ppu_buffer_addr+1, x
                    sta PPUADDR

                    ; Get length
                    ldy ppu_buffer_addr+3, x

                    ; Get vertical placement property and put it in PPUCTRL
                    lda ppu_buffer_addr+2, x
                    and #%00000100
                    ora #%10000000
                    sta PPUCTRL

                    ; Get repeating property
                    lda ppu_buffer_addr+2, x
                    and #%00000001
                    cmp #%00000001
                    bne @standard_buffer_loop

                    ; We are repeating - load the byte only once
                    lda ppu_buffer_addr+4, x
                    jmp @repeat_buffer_loop

                @standard_buffer_loop:
                    lda ppu_buffer_addr+4, x     ; Load next byte
                    sta PPUDATA                     ; Write it
                    inx                             ; Increase to next tile
                    dey                             ; Decrement tiles remaining
                    bne @standard_buffer_loop       ; Repeat until Y = 0
                    jmp @buffer_write_done           ; Skip over repeat loop

                @repeat_buffer_loop:
                    sta PPUDATA                     ; Write byte (already loaded in A)
                    dey                             ; Decrement tiles remaining
                    bne @repeat_buffer_loop         ; Repeat until Y = 0
                    inx                             ; Increase buffer position just once after this write is done

                @buffer_write_done:
                    ; Add length of our buffer data for next increment
                    inx
                    inx
                    inx
                    inx

                ; Peek ahead to see if we're done
                lda ppu_buffer_addr, x
                bne @parse_buffer
            @skip_buffer:

            ; Update PPUCTRL from RAM
            lda RAM_PPUCTRL
            ora #%10000000 ; But keep NMI on
            sta PPUCTRL

            ; Reset OAM position (reserving sprite 0 just in case)
            lda #$04
            sta oam_position

            ; Wipe the PPU buffer
            lda #$00
            sta ppu_buffer_length
            ldx #$00
            :
                sta ppu_buffer_addr, x
                inx
                bne :-

            ; Wipe OAM
            :
                ; Multiply X counter by 4 since we only need to write every fourth byte
                ; (Yes this will still be a 0 on the first loop)
                txa
                asl
                asl
                tay ; Put into Y so X can count normally
                
                lda #$ff
                sta $0200, y    ; Put the sprite Y at decimal 255 - rest of the bytes can stay
                inx
                cpx #$40        ; Cycle $40 rather than a full page (since we only set a fourth of the bytes)
                bne :-

            ; Put current bank on the stack
            lda current_bank
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

            ; vblank is done, unset flag so Logic can begin
            lda #$00
            sta vblank_waiting

            rti

        Bankswitch:
            sty current_bank
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