; Title frame logic

; If we are past frame #$20, skip
lda palette_timer
cmp #$20
bcs @EndPaletteIncrement

    ; Load the step index we are on, x4, put into scratch
    ; This value offsets where we load new palette from
    ldx #$00
    lda palette_step
    asl
    asl ; x4
    sta zp6

    ; Only write to the PPUB every 8th frame
    inc palette_timer
    lda palette_timer
    and #%00000111
    cmp #%00000111
    bne @EndPaletteIncrement
        PPUBInitM $3f00, #$00, #$04
        lda #<TitlePaletteShift
        clc
        adc zp6
        sta zp0
        lda #>TitlePaletteShift
        adc #$00
        sta zp1
        lda #$04
        sta zp2
        jsr PPUB::Multi
        inc palette_step
    @EndPaletteIncrement:

; If P1 presses enter, swap our game mode
ldx #$00
InputIsPressed BUTTON_SELECT
beq :+
    jmp @AfterSelect
:
    inc game_mode ; Only last bit is significant so we can inc it forever

    ; Play select sound
    lda #SND_SELECT
    ldx #$00
    CallFromBank #$02, famistudio_sfx_play

    ; See if we are in game mode 0 or 1 and recolor 1P and 2P labels appropriately
    lda game_mode
    and #$01
    cmp #$01
    beq @GameMode1
        ; For game mode 0 - p1 is highlighted, p2 is gray
        PPUBInitM $23db, #$01, #$02
        lda #$00
        jsr PPUB::Byte

        PPUBInitM $23e3, #$01, #$02
        lda #$55
        jsr PPUB::Byte

        jmp @AfterSelect

    @GameMode1:
        ; For game mode 1 - p1 is gray, p2 is highlighted
        PPUBInitM $23db, #$01, #$02
        lda #$55
        jsr PPUB::Byte

        PPUBInitM $23e3, #$01, #$02
        lda #$00
        jsr PPUB::Byte
        
@AfterSelect:

rts
TitlePaletteShift:
    .byte $0d, $0d, $0d, $0c
    .byte $0d, $0d, $0c, $0c
    .byte $0d, $0c, $0c, $21
    .byte $0d, $0c, $21, $20