.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
main: {
    jsr fork
    cmp #0
    bne __b1
    jsr exec
  __b3:
    jsr yield
    jmp __b3
  __b1:
    jsr showpid
    jmp __b3
    program_name: .text "program4.prg"
    .byte 0
}
showpid: {
    jsr enable_syscalls
    lda #0
    sta $d646
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
yield: {
    jsr enable_syscalls
    lda #0
    sta $d645
    nop
    rts
}
// exec(byte* zeropage(2) program_name)
exec: {
    .label str_mem = 4
    .label program_name = 2
    lda #<$300
    sta.z str_mem
    lda #>$300
    sta.z str_mem+1
    lda #<main.program_name
    sta.z program_name
    lda #>main.program_name
    sta.z program_name+1
  __b1:
    ldy #0
    lda (program_name),y
    cmp #0
    bne __b2
    tya
    tay
    sta (str_mem),y
    jsr enable_syscalls
    lda #0
    sta $d648
    nop
    rts
  __b2:
    ldy #0
    lda (program_name),y
    sta (str_mem),y
    inc.z str_mem
    bne !+
    inc.z str_mem+1
  !:
    inc.z program_name
    bne !+
    inc.z program_name+1
  !:
    jmp __b1
}
fork: {
    jsr enable_syscalls
    lda #0
    sta $d647
    nop
    lda $300
    rts
}
