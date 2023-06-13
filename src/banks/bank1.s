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

            PPUBInitMultiM $2084, #$00, #$10, $8010
            PPUBInitMultiM $20A4, #$00, #$10, $8030
            PPUBInitMultiM $20C4, #$00, #$10, $8050
            PPUBInitMultiM $20E4, #$00, #$10, $8070
            PPUBInitMultiM $2104, #$00, #$10, $8090

            ; ; Write our title block
            ; ; Disable NMIs and turn off the screen for this
            ; lda #$00
            ; sta PPUCTRL
            ; sta PPUMASK
            ; sta zp0

            ; ; Start at $2084
            ; ldy #$06 ; 6 rows
            ; lda #$a8
            ; sta zp1
            ; lda #$20
            ; sta zp2
            ; :
            ;     bit PPUSTATUS
            ;     lda zp2
            ;     sta PPUADDR
            ;     lda zp1
            ;     sta PPUADDR
            ;     ldx #$10
            ;     :
            ;         inc zp0
            ;         lda zp0
            ;         sta PPUDATA
            ;         dex
            ;         bne :-

            ;     lda zp1
            ;     clc
            ;     adc #$20
            ;     sta zp1
            ;     lda zp2
            ;     adc #$00
            ;     sta zp2
            ;     dey
            ;     cpy #$00
            ;     bne :--

            ; ; Re-enable drawing
            ; bit PPUSTATUS
            ; lda #$00
            ; sta PPUSCROLL
            ; sta PPUSCROLL
            ; lda #%10000000
            ; sta PPUCTRL
            ; lda #%00011110
            ; sta PPUMASK

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
            .include "../states/title.s"

        Placement:
            rts
            
        Shot:
            rts

        Cutscene:
            rts

        GameOver:
            rts

    .endscope