.segment "BANK0" ; Graphics data
    .scope Graphics

        Start:

        ; First 32 tiles should be blank (to allow ASCII characters to align)
        .repeat $20
            .incbin "build/blank.chr"
        .endrep

        ASCII:
            .incbin "build/blank.chr" ; ASCII $20 is space (blank tile)
            .incbin "build/ascii.chr"

        Title:
            .incbin "build/title.chr"

        Palettes:
            .byte $0d, $0d, $0d, $0d
            .byte $1d, $0c, $00, $20
            .byte $1d, $07, $26, $20
            .byte $1d, $07, $26, $20

            .byte $1d, $07, $26, $20
            .byte $1d, $07, $26, $20
            .byte $1d, $07, $26, $20
            .byte $1d, $07, $26, $20
    .endscope