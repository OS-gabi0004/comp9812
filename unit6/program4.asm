.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    lda #<message
    sta.z ipc_send.message
    lda #>message
    sta.z ipc_send.message+1
    ldx #$ff
    jsr ipc_send
    lda #<message1
    sta.z ipc_send.message
    lda #>message1
    sta.z ipc_send.message+1
    ldx #$c8
    jsr ipc_send
    lda #<message2
    sta.z ipc_send.message
    lda #>message2
    sta.z ipc_send.message+1
    ldx #$c7
    jsr ipc_send
    lda #<message3
    sta.z ipc_send.message
    lda #>message3
    sta.z ipc_send.message+1
    ldx #$c6
    jsr ipc_send
    lda #<message2
    sta.z ipc_send.message
    lda #>message2
    sta.z ipc_send.message+1
    ldx #1
    jsr ipc_send
    lda #<message5
    sta.z ipc_send.message
    lda #>message5
    sta.z ipc_send.message+1
    ldx #$64
    jsr ipc_send
    lda #<message6
    sta.z ipc_send.message
    lda #>message6
    sta.z ipc_send.message+1
    ldx #$f0
    jsr ipc_send
  __b1:
    jsr yield
    jmp __b1
    message: .text "checkpoint  "
    .byte 0
    message1: .text "4           "
    .byte 0
    message2: .text "------------"
    .byte 0
    message3: .text "moremessages"
    .byte 0
    message5: .text "3           "
    .byte 0
    message6: .text "6.          "
    .byte 0
}
yield: {
    jsr enable_syscalls
    lda #0
    sta $d645
    nop
    rts
}
enable_syscalls: {
    lda #$47
    sta $d02f
    lda #$53
    sta $d02f
    rts
}
// ipc_send(byte register(X) priority, byte* zeropage(2) message)
ipc_send: {
    .label msg = $303
    .label i = 4
    .label message = 2
    .label __6 = 6
    .label __7 = 8
    lda #1
    sta $300
    stx $301
    sta $302
    lda #<0
    sta.z i
    sta.z i+1
  __b1:
    lda.z i+1
    cmp #>$c
    bcc __b2
    bne !+
    lda.z i
    cmp #<$c
    bcc __b2
  !:
    jsr enable_syscalls
    lda #0
    sta $d64a
    rts
  __b2:
    lda.z message
    clc
    adc.z i
    sta.z __6
    lda.z message+1
    adc.z i+1
    sta.z __6+1
    lda #<msg
    clc
    adc.z i
    sta.z __7
    lda #>msg
    adc.z i+1
    sta.z __7+1
    ldy #0
    lda (__6),y
    sta (__7),y
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b1
}
