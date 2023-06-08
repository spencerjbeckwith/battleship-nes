.segment "ZEROPAGE"
    ; Scratch work
    zp0: .res 1
    zp1: .res 1
    zp2: .res 1
    zp3: .res 1
    zp4: .res 1
    zp5: .res 1
    zp6: .res 1
    zp7: .res 1
    zp8: .res 1
    zp9: .res 1
    zp10: .res 1
    zp11: .res 1
    zp12: .res 1
    zp13: .res 1
    zp14: .res 1
    zp15: .res 1

    ; Other ZP variables
    current_bank: .res 1
    vblank_waiting: .res 1
    oam_position: .res 1
    ppu_buffer_length: .res 1
    RAM_PPUCTRL: .res 1
    RAM_PPUMASK: .res 1

    state: .res 1
    state_prev: .res 1
    
.segment "RAM"

    .org $0500
        palette_timer: .res 1
        palette_step: .res 1

    .org $0700
        ; Reserve a page for queued writes to the PPU
        ppu_buffer_addr: .res 256

    .reloc

; Constants
PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
OAMADDR = $2003
OAMDATA = $2004
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007

OAMDMA = $4014