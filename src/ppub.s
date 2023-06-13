.scope PPUB

    ; Macro for calling PPUB::Init
    .macro PPUBInitM addr, flags, length
        .if .paramcount <> 3
            .error "InitM macro needs 3 parameters! PPUB::InitM <addr> <flags> <length>"
        .endif
        lda #<addr
        sta zp0
        lda #>addr
        sta zp1
        lda flags
        sta zp2
        lda length
        sta zp3
        jsr PPUB::Init
    .endmacro
    
    ; Macro for calling PPUB::Multi
    .macro PPUBMultiM label, length
        .if .paramcount <> 2
            .error "MultiM macro needs 2 parameters! PPUB::MultiM <label> <length>"
        .endif
        lda #<label
        sta zp0
        lda #>label
        sta zp1
        lda length
        sta zp2
        jsr PPUB::Multi
    .endmacro

    ; Macro for both initializing and writing multiple bytes to the buffer simultaneously
    .macro PPUBInitMultiM addr, flags, length, label
        PPUBInitM addr, flags, length
        PPUBMultiM label, length
    .endmacro

    ; Subroutine that initializes a new entry to the PPU buffer
    ; You must use PPUB::Byte or PPUB:Multi to fill this entry.
    ; zp0 - low byte of PPU address to write to
    ; zp1 - high byte of PPU address to write to
    ; zp2 - flags byte
    ; zp3 - length of bytes that will be written
    Init:
        ldx ppu_buffer_length
        lda zp0 
        sta ppu_buffer_addr, x
        inx
        lda zp1
        sta ppu_buffer_addr, x
        inx
        lda zp2
        sta ppu_buffer_addr, x
        inx
        lda zp3
        sta ppu_buffer_addr, x
        inx
        stx ppu_buffer_length
        rts

    ; Subroutine that writes a single byte (the value of the accumulator) to the PPU buffer
    Byte:
        ldx ppu_buffer_length
        sta ppu_buffer_addr, x
        inx
        sta ppu_buffer_length
        rts

    ; Subroutine that writes multiple bytes (from a label in memory) to the PPU buffer
    ; zp0: low byte of label where bytes begin
    ; zp1: high byte of label where bytes begin
    ; zp2: length of bytes to write
    Multi:
        ldx ppu_buffer_length
        ldy #$00
        @MultiLoop:
            lda (zp0), y
            sta ppu_buffer_addr, x
            inx
            iny
            cpy zp2
            bne @MultiLoop
        stx ppu_buffer_length
        rts

.endscope