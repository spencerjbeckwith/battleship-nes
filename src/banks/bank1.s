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
            jsr PPUB::DisableRendering

            ; Start at $2084
            lda #$5a
            sta zp2
            ldy #$06 ; 6 rows for the title
            lda #$a8
            sta zp0
            lda #$20
            sta zp1
            :
                jsr PPUB::InitDirect
                ldx #$10
                :
                    inc zp2
                    lda zp2
                    sta PPUDATA
                    dex
                    bne :-
                lda zp0
                clc
                adc #$20
                sta zp0
                lda zp1
                adc #$00
                sta zp1
                dey
                cpy #$00
                bne :--

            ; Write strings to bottom of the screen
            PPUBInitMultiDirectM $230c, #$08, NameAndYear
            PPUBInitMultiDirectM $2342, #$1c, Github1
            PPUBInitMultiDirectM $2369, #$0e, Github2
            PPUBInitMultiDirectM $23f0, #$08, Attributes

            ; Re-enable drawing
            jsr PPUB::EnableRendering

            ; Initialize palette timer for fade-in animation
            lda #$00
            sta palette_timer

            rts

        NameAndYear: .byte "SJB 2O23"
        Github1: .byte "GITHUB.COM/SPENCERJBECKWITH/"
        Github2: .byte "BATTLESHIP-NES"
        Attributes:
            .repeat 8
                .byte $55 ; %01010101 -> palette 1 for all the notice text
            .endrep

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