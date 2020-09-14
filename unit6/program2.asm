.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    jsr ipc_send
  __b1:
    jsr yield
    jmp __b1
    message: .text "cpoint 6.2  "
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
ipc_send: {
    .label msg = $303
    .const to = 1
    .const priority = 1
    .const sequence_number = 1
    .label i = 2
    .label __6 = 4
    .label __7 = 6
    lda #to
    sta $300
    lda #priority
    sta $301
    lda #sequence_number
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
    lda #<main.message
    clc
    adc.z i
    sta.z __6
    lda #>main.message
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
