.scope Input

    ; Use this macro to check if a button is currently held.
    ; X register should contain 0 to check P1 and 1 to check P2.
    .macro InputIsHeld button
        lda inputs_held, x
        and #button
        cmp #button
    .endmacro

    ; Use this macro to check if a button was pressed this frame.
    ; X register should contain 0 to check P1 and 1 to check P2.
    .macro InputIsPressed button
        lda inputs_pressed, x
        and #button
        cmp #button
    .endmacro

    ; Use this macro to check if a button was released this frame.
    ; X register should contain 0 to check P1 and 1 to check P2.
    .macro InputIsReleased button
        lda inputs_released, x
        and #button
        cmp #button
    .endmacro

    ; Example using the input macros:
    ;   ldx #$01 ; P2
    ;   InputIsPressed BUTTON_A
    ;   bne @AfterAPress
    ;       ; do stuff here...
    ;   @AfterAPress:

    Read:
        ; Keep polling until we get two results in a row
        ldx #$00
        @NextPlayer:
            jsr PollController
            @ReadAgain:
                lda inputs_held, x
                pha
                jsr PollController
                pla
                cmp inputs_held, x
                bne @ReadAgain

            ; Calculate released buttons
            lda inputs_held, x
            eor #$ff                ; Invert current buttons...
            and inputs_previous, x  ; AND with the last frame's buttons...
            sta inputs_released, x  ; ...to get what was released this frame

            ; Calculate pressed buttons
            lda inputs_previous, x
            eor #$ff                ; Invert last frames buttons...
            and inputs_held, x      ; AND with current buttons...
            sta inputs_pressed, x   ; ...to get what was pressed this frame

            ; Store current as previous for next frame
            lda inputs_held, x
            sta inputs_previous, x

            ; Start over again, reading for P2 this time
            inx
            cpx #$02
            bne @NextPlayer
        
        rts

    PollController:
        lda #$01
        sta $4016
        sta inputs_held, x
        lda #$00
        sta $4016
        @Roll:
            cpx #$01
            beq @ReadP2
                lda $4016 ; Read P1
                jmp @AfterRead
            @ReadP2:
                lda $4017 ; Read P2
            @AfterRead:
            lsr a
            rol inputs_held, x
            bcc @Roll
        rts

.endscope