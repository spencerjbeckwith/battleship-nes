.include "lib/famistudio_ca65.s"
; FamiStudio emits itself into RODATA so I commented that out
; But we do have to redefine BANK2 segment here

.segment "BANK2"
    MusicData:
        ; .include "../build/music.s"
    SoundData:
        .include "../build/sfx.s"

SND_SELECT = $00
SND_AIM = $01
SND_FIRE = $02
SND_FALL = $03
SND_SPLASH = $04
SND_HIT = $05
SND_START = $06