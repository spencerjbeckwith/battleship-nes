.segment "HEADER"
    .byte "NES", $1a
    .byte $08, $00      ; 4/5: PRG-ROM size, no CHR-ROM
    .byte %00100001     ; 6: Mapper 2 (UNROM), vertical mirroring
    .byte %00001000     ; 7: iNES 2.0 format
    .byte $00, $00, $00 ; No submapper, PRG-ROM > 4MB, or RPG-RAM
    .byte $07           ; 8k CHR-RAM, no battery
    .byte $00, $00      ; NTSC, no special PPU

.include "ram.s"

.rodata
    .include "ppub.s"
    .include "input.s"

    ; You MUST use this macro when calling a subroutine from another bank if the PC is currently below $C000.
    ; Example usage:
    ;   lda #SND_SELECT
    ;   ldx #$00
    ;   CallFromBank #$02, famistudio_sfx_play ; FamiStudio is in bank 2

    .macro CallFromBank bank, subroutine
    
        ; Hacky-shit explanation:
        ; I made the mistake of putting program code in the banks, which means if we want to call code for
        ; one bank from another (primary example being playing sounds and music) you MUST use this macro.
        ; If you JSR directly, or switch banks before your JSR, you'll almost certainly crash. You must switch banks
        ; while the PC is >$C000 or you're ripping out the bank from underneath yourself and changing your next instructions.

        ; This macro handles the necessary bank switches before and after the subroutine from a separate bank you're trying to call.
        ; It also preserves your registers and zp going in - so it is as if you called a bank directly from another.
        ; A better solution for sounds is a "sound-queue" we'd handle in the NMI, but this macro will work for any and all bank-specific code.

        ; Save registers in RAM
        sta reserved
        stx reserved+1
        sty reserved+2

        lda #>subroutine
        sta reserved+3
        lda #<subroutine-1
        sta reserved+4
        lda bank
        sta reserved+5
        jsr _CallFromBank
    .endmacro

    ; Queues an event to be called from a bank, after the specified number of frames have occured.
    ; Example usage:
    ; QueueEvent #$01, #$20, BeginGame
    .macro QueueEvent bank, frames, subroutine
        lda bank
        sta zp0
        lda frames
        sta zp1
        lda #<subroutine
        sta zp2
        lda #>subroutine
        sta zp3
        jsr _QueueEvent
    .endmacro

    ; Call to switch banks.
    ; Y should be set to the bank index you want to switch to. Must be $00-$06.
    Bankswitch:
        sty current_bank
        lda Banktable, y
        sta Banktable, y
        rts

        Banktable:
            .byte $00, $01, $02, $03, $04, $05, $06

    _CallFromBank:
        ; Save the old and switch the current bank
        lda current_bank
        pha
        ldy reserved+5
        jsr Bankswitch
        
        ; Push "exit" address from subroutine (>$C000)
        lda #>_ReturnFromBank
        pha
        lda #<_ReturnFromBank-1
        pha

        ; Push "return" of the subroutine we set (<$C000, after bank is switched back)
        lda reserved+3
        pha
        lda reserved+4
        pha

        ; Re-load registers going into the subroutine
        lda reserved
        ldx reserved+1
        ldy reserved+2
        rts

    _ReturnFromBank:
        ; Switch back to our old bank
        pla
        tay
        jsr Bankswitch
        rts

    _QueueEvent:
        ; Put event in our next unused event spot
        ldx #$00
        @AttemptEventSlot:
            lda events+1, x
            bne @EventSlotOccupied

            lda zp0
            sta events, x
            lda zp1
            sta events+1, x
            lda zp2
            sta events+2, x
            lda zp3
            sta events+3, x
            rts

        @EventSlotOccupied:
            inx
            inx
            inx
            inx
            jmp @AttemptEventSlot

.include "banks/bank0.s"
.include "banks/bank1.s"
.include "banks/bank2.s"
.include "banks/bank3.s"
.include "banks/bank4.s"
.include "banks/bank5.s"
.include "banks/bank6.s"

.rodata
    .scope Main

        Initialization:
            sei
            cld
            ldx #$40
            stx $4017 ; Disable IRQ
            ldx #$ff
            txs
            inx
            stx PPUCTRL ; Disable vblank
            stx PPUMASK ; Disable rendering
            stx $4010 ; Disable DMC IRQs

            : ; Wait for a vblank
                bit PPUSTATUS
                bpl :-
        
            : ; Wipe RAM
                lda #$00
                sta $0000, x
                sta $0100, x
                sta $0300, x
                sta $0400, x
                sta $0500, x
                sta $0600, x
                sta $0700, x

                lda #$ff
                sta $0200, x ; Put $ff into OAM instead of $00

                inx
                bne :-

            : ; Wait for another vblank
                bit PPUSTATUS
                bpl :-

            ; Switch to first bank
            ldy #$00
            jsr Bankswitch

            ; Load CHR-RAM
            lda #>Graphics::Start
            sta zp1
            lda #<Graphics::Start
            sta zp0

            bit PPUSTATUS   ; Reset latch
            lda #$00
            sta PPUADDR     ; Set address in PPU to $0000
            sta PPUADDR
            ldx #$20        ; Copy $20 (32) pages
            :
                lda (zp0), y
                sta PPUDATA
                iny
                bne :-

                inc zp1     ; To next page
                dex
                bne :-      ; When zero pages are left, continue on

            ; Load palettes
            bit PPUSTATUS
            lda #$3f
            sta PPUADDR
            stx PPUADDR
            :
                lda Graphics::Palettes, x
                sta PPUDATA
                inx
                cpx #$20    ; Copy $20 (32) bytes
                bne :-

            ; Initialize music and sound
            ldy #$02
            jsr Bankswitch  ; Sound data is in bank 2
            lda #$01        ; Non-PAL
            ldx #<MusicData
            ldy #>MusicData
            jsr famistudio_init
            ldx #<SoundData
            ldy #>SoundData
            jsr famistudio_sfx_init

            ; Reset scroll
            bit PPUSTATUS
            lda #$00
            sta PPUSCROLL
            sta PPUSCROLL

            ; Begin OAM after sprite 0
            lda #$04
            sta oam_position

            ; Initialize game state
            lda #STATE_TITLE
            sta state

            ; Enable vblank
            lda #%10000000
            sta RAM_PPUCTRL
            sta PPUCTRL
            lda #%00011110
            sta PPUMASK

        Logic:
            ; Infinite loop, for now
            inc vblank_waiting
            :
                lda vblank_waiting
                bne :-

            ; Read inputs
            jsr Input::Read

            ; Execute queued events
            ldx #$00
            ldy #$00
            @NextEvent:
                lda events+1, x
                beq @ToNextEvent

                    ; Decrement frames left
                    sec
                    sbc #$01
                    sta events+1, x

                    ; Are we at zero now?
                    cmp #$00
                    bne @ToNextEvent

                        ; Yes, we are at zero. Execute the event
                        ; Preserve registers for the rest of the loop
                        tya
                        pha
                        txa
                        pha

                        ; Switch to the right bank
                        ldy events, x
                        jsr Bankswitch

                        ; Push exit address to stack
                        lda #>@EventOver
                        pha
                        lda #<@EventOver-1
                        pha

                        ; Push routine address to stack
                        lda events+3, x ; High byte first...
                        pha
                        lda events+2, x ; Low byte minus 1
                        sec
                        sbc #$01
                        pha
                        rts

                    @EventOver:

                        ; Restore registers and move on
                        pla
                        tax
                        pla
                        tay

                @ToNextEvent:
                    ; Are we done with our queue yet?
                    iny
                    cpy #EVENT_COUNT
                    beq @AllEventsDone

                    ; We have events left
                    inx
                    inx
                    inx
                    inx
                    jmp @NextEvent

            @AllEventsDone:

            ; Run the state machine (in bank 1)
            ldy #$01
            jsr Bankswitch

            ; This works by pushing several pointers into the stack
            ; so that these functions can rts directly to one another.

            ; StateCleanup -> StateInit -> State -> Logic
            ; To rts in the right order, these must be pushed onto the stack in reverse.
            ; Call me the rts trickster 😎 maybe I should change my username to rtstrickstr...

            ; "Exit" point is our Logic loop
            lda #>Logic
            pha
            lda #<Logic-1
            pha

            ; Push current state to stack
            lda state
            asl
            tax ; Multiply state by 2 (as our addresses are 16-bit)
            lda StateTable+1, x
            pha
            lda StateTable, x
            sec
            sbc #$01
            pha

            ; If state has changed from the last frame:
            lda state
            cmp state_prev
            beq :+

                ; Push init from the new state to stack
                asl
                tax
                lda StateInitTable+1, x
                pha
                lda StateInitTable, x
                sec
                sbc #$01
                pha

                ; Push cleanup from last state to stack
                lda state_prev
                asl
                tax
                lda StateCleanupTable+1, x
                pha
                lda StateCleanupTable, x
                sec
                sbc #$01
                pha
            :
            
            ; Launch our rts chain
            lda state
            sta state_prev
            rts

        NMI:
            ; Push all registers to the stack
            pha
            txa
            pha
            tya
            pha

            ; OAMDMA
            lda #$00
            sta OAMADDR
            lda #$02
            sta OAMDMA

            ; Read updates from the PPU buffer
            ; Every PPU buffer entry is at least five bytes and takes the following format:
            ; (PPU address high, PPU address low, flags, length, data byte, [data byte...])
            ; Flags byte format:
            ; 7 6 5 4 3 2 1 0
            ; | | | | | | | +-- repeat. If 1, the first and only data byte will be written (length) times instead of writing (length) bytes from the buffer
            ; | | | | | | +---- increment. If repeat is also 1, every write will increment the value being written by 1
            ; | | | | | +------ vertical placement property. If 1, writes occur vertically in the PPU (increment by a $20 instead of $01)
            lda ppu_buffer_addr+1
            beq @skip_buffer    ; Skip buffer if first entry is 0, meaning no changes were made
                ldx #$00        ; X will track position in the buffer
                @parse_buffer:

                    ; Reset latch and set our target address in the PPU
                    ; Note that the bytes should be high-endian, but the buffer is low-endian (for abstracted consistency)
                    bit PPUSTATUS
                    lda ppu_buffer_addr+1, x
                    sta PPUADDR
                    lda ppu_buffer_addr, x
                    sta PPUADDR

                    ; Get length
                    ldy ppu_buffer_addr+3, x

                    ; Get vertical placement property and put it in PPUCTRL
                    lda ppu_buffer_addr+2, x
                    and #%00000100
                    ora #%10000000
                    sta PPUCTRL

                    ; Get repeating property
                    lda ppu_buffer_addr+2, x
                    and #$01
                    cmp #$01
                    bne @standard_buffer_loop

                    ; Get incrementing property
                    lda ppu_buffer_addr+2, x
                    and #$02
                    cmp #$02
                    beq @increment_buffer_start

                    ; We are repeating - load the byte only once
                    lda ppu_buffer_addr+4, x
                    jmp @repeat_buffer_loop

                @standard_buffer_loop:
                    lda ppu_buffer_addr+4, x        ; Load next byte
                    sta PPUDATA                     ; Write it
                    inx                             ; Increase to next tile
                    dey                             ; Decrement tiles remaining
                    bne @standard_buffer_loop       ; Repeat until Y = 0
                    jmp @buffer_write_done          ; Skip over repeat loop

                @repeat_buffer_loop:
                    sta PPUDATA                     ; Write byte (already loaded in A)
                    dey                             ; Decrement tiles remaining
                    bne @repeat_buffer_loop         ; Repeat until Y = 0
                    inx                             ; Increase buffer position just once after this write is done
                    jmp @buffer_write_done

                @increment_buffer_start:
                    lda ppu_buffer_addr+4, x
                    clc

                @increment_buffer_loop:
                    sta PPUDATA
                    adc #$01
                    dey
                    bne @increment_buffer_loop
                    inx

                @buffer_write_done:
                    ; Add length of our buffer data for next increment
                    inx
                    inx
                    inx
                    inx

                ; Peek ahead to see if we're done
                lda ppu_buffer_addr, x
                bne @parse_buffer
            @skip_buffer:

            ; Keep scroll at 0
            bit PPUSTATUS
            lda #$00
            sta PPUSCROLL
            sta PPUSCROLL

            ; Update PPUCTRL from RAM
            lda RAM_PPUCTRL
            ora #%10000000 ; But keep NMI on
            sta PPUCTRL

            ; Reset OAM position (reserving sprite 0 just in case)
            lda #$04
            sta oam_position

            ; Wipe the PPU buffer
            lda #$00
            sta ppu_buffer_length
            ldx #$00
            :
                sta ppu_buffer_addr, x
                inx
                bne :-

            ; Wipe OAM
            :
                ; Multiply X counter by 4 since we only need to write every fourth byte
                ; (Yes this will still be a 0 on the first loop)
                txa
                asl
                asl
                tay ; Put into Y so X can count normally
                
                lda #$ff
                sta $0200, y    ; Put the sprite Y at decimal 255 - rest of the bytes can stay
                inx
                cpx #$40        ; Cycle $40 rather than a full page (since we only set a fourth of the bytes)
                bne :-

            ; Put current bank on the stack
            lda current_bank
            pha

            ; Sound/music step
            ldy #$02
            jsr Bankswitch
            jsr famistudio_update

            ; Return to old bank
            pla
            tay
            jsr Bankswitch

            ; Pull registers off the stack and return
            pla
            tay
            pla
            tax
            pla

            ; vblank is done, unset flag so Logic can begin
            lda #$00
            sta vblank_waiting

            rti

        StateInitTable:
            .word StateInit::Boot
            .word StateInit::Title
            .word StateInit::Placement
            .word StateInit::Shot
            .word StateInit::Cutscene
            .word StateInit::GameOver

        StateCleanupTable:
            .word StateCleanup::Boot
            .word StateCleanup::Title
            .word StateCleanup::Placement
            .word StateCleanup::Shot
            .word StateCleanup::Cutscene
            .word StateCleanup::GameOver

        StateTable:
            .word State::Boot
            .word State::Title
            .word State::Placement
            .word State::Shot
            .word State::Cutscene
            .word State::GameOver

    .endscope

.segment "VECTORS"
    .word Main::NMI
    .word Main::Initialization
    .byte $00, $00 ; No IRQ
