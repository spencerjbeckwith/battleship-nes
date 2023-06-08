.segment "BANK0" ; Graphics data
    Graphics:

        ; Tile 0 should be blank
        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00

        .incbin "build/title.chr"

    Palettes:
        .byte $0d, $0d, $0d, $0d
        .byte $1d, $07, $26, $20
        .byte $1d, $07, $26, $20
        .byte $1d, $07, $26, $20

        .byte $1d, $07, $26, $20
        .byte $1d, $07, $26, $20
        .byte $1d, $07, $26, $20
        .byte $1d, $07, $26, $20