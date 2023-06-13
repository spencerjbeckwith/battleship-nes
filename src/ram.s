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

    .org $0300
        ; Reserve a page for board information
        player_data: .res 256

    .org $0500
        palette_timer: .res 1
        palette_step: .res 1

    .org $0700
        ; Reserve a page for queued writes to the PPU
        ppu_buffer_addr: .res 256

    .reloc

; Note that player data should be looked at from the perspective of the player being shot at, not whoever's turn it is
player_losses = $0300
player_hits_cv = $0301
player_hits_bb = $0302
player_hits_ca = $0303
player_hits_ss = $0304
player_hits_dd = $0305
player_data_length = $6a ; 106 bytes per player - the 6 above and the 10x10 grid
; Format of each tile byte is as follows:
; 76543210
; xxxxHBBB
; |||||+++- BBB: the type of ship in this tile
; ||||+---- H: if this tile/ship was shot or not yet by the opposing player

; Ship types:
; 000 0 - no ship
; 001 1 - carrier (cv) - length of 5
; 010 2 - battleship (bb) - length of 4
; 011 3 - cruiser (ca) - length of 3
; 100 4 - submarine (ss) - length of 3
; 101 5 - destroyer (dd) - length of 2

; If tile value > 8, a ship has been hit there
; If tile value <= 8, tile hasn't been shot yet but it may have a ship

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