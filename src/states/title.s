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

rts
TitlePaletteShift:
    .byte $0d, $0d, $0d, $0c
    .byte $0d, $0d, $0c, $0c
    .byte $0d, $0c, $0c, $21
    .byte $0d, $0c, $21, $20