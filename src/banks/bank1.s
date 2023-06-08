.segment "BANK1" ; State logic

    ; How many states does this game need?
    ; 0: bootup state
    ; 1: title screen state (ends when user selects 1 or 2 player)
    ; 2: ship placement screen
    ; 3: take a shot
    ; 4: hit/miss "cutscene"
    ; 5: victory or game over

    STATE_BOOT = $00
    STATE_TITLE = $01
    STATE_PLACEMENT = $02
    STATE_SHOT = $03
    STATE_CUTSCENE = $04
    STATE_GAMEOVER = $05

    ; Runs when each state is initialized
    .scope StateInit
        Boot:
            rts

        Title:
            ; Write our title block
            ; Disable NMIs and turn off the screen for this
            lda #$00
            sta PPUCTRL
            sta PPUMASK
            sta zp0

            ; Start at $2084
            ldy #$06 ; 6 rows
            lda #$a8
            sta zp1
            lda #$20
            sta zp2
            :
                bit PPUSTATUS
                lda zp2
                sta PPUADDR
                lda zp1
                sta PPUADDR
                ldx #$10
                :
                    inc zp0
                    lda zp0
                    sta PPUDATA
                    dex
                    bne :-

                lda zp1
                clc
                adc #$20
                sta zp1
                lda zp2
                adc #$00
                sta zp2
                dey
                cpy #$00
                bne :--

            ; Re-enable drawing
            bit PPUSTATUS
            lda #$00
            sta PPUSCROLL
            sta PPUSCROLL
            lda #%10000000
            sta PPUCTRL
            lda #%00011110
            sta PPUMASK

            lda #$00
            sta palette_timer

            rts

        Placement:
            rts

        Shot:
            rts

        Cutscene:
            rts

        GameOver:
            rts

    .endscope

    ; Runs when each state is cleaned up
    .scope StateCleanup
        Boot:
            rts

        Title:
            rts

        Placement:
            rts

        Shot:
            rts

        Cutscene:
            rts

        GameOver:
            rts

    .endscope

    ; Runs every frame of each state
    .scope State
        Boot:
            rts

        Title:
            lda #<TitlePaletteShift
            sta zp0
            lda #>TitlePaletteShift
            sta zp1
            jsr PaletteIncrement
            rts
            
            TitlePaletteShift:
                .byte $0d, $0d, $0d, $0c
                .byte $0d, $0d, $0c, $0c
                .byte $0d, $0c, $0c, $21
                .byte $0d, $0c, $21, $20

        Placement:
            rts
            
        Shot:
            rts

        Cutscene:
            rts

        GameOver:
            rts

        ; Common routines for ecah state
        PaletteIncrement:
            ; This will increment four palettes over 32 frames according to the provided little-endian address.
            ; zp0: palette table low byte
            ; zp1: palette table high byte
            ; For this routine to take affect, you must set palette_timer to $00.
            ; For best results, coordinate your shifted colors for a smooth transition

            ; Issue with this: only works for the first palette. How can we make this work for multiple palettes in the 3fxx PPU range?

            ; Exit subroutine early if our timer is at the max
            lda palette_timer
            cmp #$20
            bcc :+
                rts
            :

            ldx #$00
            lda palette_step
            asl
            asl ; x4
            tay

            inc palette_timer
            lda palette_timer
            and #%00000111
            cmp #%00000111
            bne :++

                ; TODO make this a macro or subroutine?
                ; This is a fairly unintuitive routine

                ldx ppu_buffer_length
                lda #$3f
                sta ppu_buffer_addr, x
                inx

                lda #$00 ; <-- change me to start at a different palette
                sta ppu_buffer_addr, x
                inx

                sta ppu_buffer_addr, x
                inx

                lda #$04 ; Only write four bytes into the buffer - change me for more
                sta ppu_buffer_addr, x
                sta zp2
                inx

                ; Write the bytes from our table
                :
                    lda (zp0), y
                    sta ppu_buffer_addr, x
                    inx
                    iny
                    dec zp2
                    bne :-
                inc palette_step
            :

            rts

    .endscope