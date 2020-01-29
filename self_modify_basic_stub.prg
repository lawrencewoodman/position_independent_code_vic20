;=====================================================
; Example of Self Modifying Position Independent Code
; Lawrence Woodman <lwoodman@vlifesystems.com>
; 24 January 2020
;=====================================================

; Basic Stub
OPEN_PR    = $28               ; ( character
CLOSE_PR   = $29               ; ) character
PLUS       = $AA               ; + character
TIMES      = $AC               ; * character
TOK_PEEK   = $C2               ; PEEK token
TOK_SYS    = $9E               ; SYS token

; Self Modification
TXTTAB     = $2B               ; Pointer to start of tokenized Basic
SMADDR     = $09               ; Address to modify
PSMTABLE   = $FB               ; Pointer to self-modification table

; Character output
CHR_RTN    = $0D               ; Return character
CCHROUT    = $FFD2             ; Output character to current output device

            ;=========================================
            ;  Basic Stub
            ;=========================================
            .byt $01, $80      ; Load Address.  Using character ROM because
                               ; correct RAM location memory configuration
                               ; dependent

            ; 2020 SYS PEEK(43)+PEEK(44)*256+27
            * = $1001
start       .word basicEnd     ; Next Line link, here end of Basic program
            .word 2020         ; The line number for the SYS statement
            .byt  TOK_SYS      ; SYS token
            .asc  " "
            .byt  TOK_PEEK     ; PEEK token
            .byt  OPEN_PR      ; (
            .asc  "43"         ; 43
            .byt  CLOSE_PR     ; )
            .byt  PLUS         ; +
            .byt  TOK_PEEK     ; PEEK token
            .byt  OPEN_PR      ; (
            .asc  "44"         ; 44
            .byt  CLOSE_PR     ; )
            .byt  TIMES        ; *
            .asc  "256"        ; 256
            .byt  PLUS         ; +
            .asc  "27"         ; 27 (The size of the stub)
            .byt  0            ; End of Basic line
basicEnd    .word 0            ; End of Basic program


            ;=========================================
            ; Start of machine language
            ;=========================================

            ; BRanch Always
            clv
            bvc setupSM

            ;-----------------------------------------
            ; Message strings
            ;-----------------------------------------
helloMsg   .asc "HELLO, WORLD!" : .byt CHR_RTN : .byt 0
byeMsg     .asc "GOODBYE, WORLD!" : .byt CHR_RTN : .byt 0

            ;=========================================
            ; Self-modification
            ;=========================================

            ;-----------------------------------------
            ; Self-modification table
            ; offsetAddr  :  offsetValue
            ;-----------------------------------------
smTable     .word main-start+1       : .word SayHello-start
            .word main-start+4       : .word SayGoodbye-start
            .word SayHello-start+3   : .word helloMsg-start
            .word SayGoodbye-start+3 : .word byeMsg-start
            .word 0            ; End of table

            ;-----------------------------------------
            ; Self-modify code to point to correct
            ; locations
            ;-----------------------------------------

setupSM     .(
            ; Create pointer to smTable
            clc
            lda TXTTAB         ; Get start of tokenized Basic
            adc #<(smTable-start)
            sta PSMTABLE
            lda TXTTAB+1
            adc #>(smTable-start)
            sta PSMTABLE+1

            ; Point offsets in smTable to absolute addresses
            ldx #00
            ldy #00
            lda (PSMTABLE), y
loop       ; Calculate address to change
            clc
            adc TXTTAB
            sta SMADDR
            iny
            lda TXTTAB+1
            adc (PSMTABLE), y
            iny
            sta SMADDR+1
            ; Calculate and store value
            clc
            lda TXTTAB
            adc (PSMTABLE), y
            iny
            sta (SMADDR, x)
            lda TXTTAB+1
            adc (PSMTABLE), y
            iny
            ; Increment address
            inc SMADDR
            bne lastStore
            inc SMADDR+1

lastStore   sta (SMADDR, x)
            lda (PSMTABLE), y
            bne loop           ; If not end of table
.)

            ;=========================================
            ; MAIN program
            ;=========================================
main:       jsr SayHello
            jsr SayGoodbye
            rts


            ;=========================================
            ; Subroutines
            ;=========================================

            ;-----------------------------------------
            ; SayHello
            ; Displays 'HELLO, WORLD!' message
            ;-----------------------------------------
SayHello    .(
            ; Output message
            ldy #$00
loop        lda helloMsg, y
            beq finished
            jsr CCHROUT        ; Output char to screen
            iny
            bne loop
finished    rts
.)


            ;-----------------------------------------
            ; SayGoodbye
            ; Displays 'GOODBYE, WORLD!' message
            ;-----------------------------------------
SayGoodbye  .(
            ; Output message
            ldy #$00
loop        lda byeMsg, y
            beq finished
            jsr CCHROUT        ; Output char to screen
            iny
            bne loop
finished    rts
.)