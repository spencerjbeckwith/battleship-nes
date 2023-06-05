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
    RAM_PPUCTRL: .res 1
    RAM_PPUMASK: .res 1
    
.segment "RAM"
    ; Non-ZP memory reservations go here

; Constants
PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007