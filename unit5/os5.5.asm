// XMega65 Kernal Development Template
// Each function of the kernal is a no-args function
// The functions are placed in the SYSCALLS table surrounded by JMP and NOP
  .file [name="os5.5.bin", type="bin", segments="XMega65Bin"]
.segmentdef XMega65Bin [segments="Syscall, Code, Data, Stack, Zeropage"]
.segmentdef Syscall [start=$8000, max=$81ff]
.segmentdef Code [start=$8200, min=$8200, max=$bdff]
.segmentdef Data [startAfter="Code", min=$8200, max=$bdff]
.segmentdef Stack [min=$be00, max=$beff, fill]
.segmentdef Zeropage [min=$bf00, max=$bfff, fill]
  .const SIZEOF_WORD = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE = 1
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME = 2
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS = 4
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS = 8
  .const OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE = $c
  .label RASTER = $d012
  .label VIC_MEMORY = $d018
  .label SCREEN = $400
  .label BGCOL = $d021
  .label COLS = $d800
  .const BLACK = 0
  .const WHITE = 1
  .const STATE_NOTRUNNING = 0
  .const STATE_NEW = 1
  .const STATE_READY = 2
  .const STATE_READYSUSPENDED = 3
  .const STATE_BLOCKEDSUSPENDED = 4
  .const STATE_BLOCKED = 5
  .const STATE_RUNNING = 6
  .const STATE_EXIT = 7
  // Process stored state will live at $C000-$C7FF, with 256 bytes
  // for each process reserved
  .label stored_pdbs = $c000
  // 8 processes x 16 bytes = 128 bytes for names
  .label process_names = $c800
  // 8 processes x 64 bytes context state = 512 bytes
  .label process_context_states = $c900
  .const JMP = $4c
  .const NOP = $ea
  .label running_pdb = $2a
  .label pid_counter = $47
  .label lpeek_value = $48
  .label current_screen_line = $1b
  .label current_screen_x = $2c
  // Which is the current running process?
  lda #$ff
  sta.z running_pdb
  // Counter for helping determine the next available proccess ID.
  lda #0
  sta.z pid_counter
  lda #$12
  sta.z lpeek_value
  lda #<SCREEN
  sta.z current_screen_line
  lda #>SCREEN
  sta.z current_screen_line+1
  lda #0
  sta.z current_screen_x
  jsr main
  rts
.segment Code
main: {
    rts
}
cpukil: {
    jsr undefined_trap
    rts
}
//XXX -  Copy your syscall handler functions from os5.2.kc
//XXX - Don't forget to add describe_pdb(running_pdb); to your handler for SYSCALL $03\
undefined_trap: {
    rts
}
reservd: {
    jsr undefined_trap
    rts
}
vf011wr: {
    jsr undefined_trap
    rts
}
vf011rd: {
    jsr undefined_trap
    rts
}
alttabkey: {
    jsr undefined_trap
    rts
}
restorkey: {
    jsr undefined_trap
    rts
}
//XXX - Copy your trap handler functions and entry point tables from os5.2.kc
pagfault: {
    jsr undefined_trap
    rts
}
//XXX - Copy your RESET() routine from os5.2.kc
//XXX - Don't forget to call resume_pdb(0) immediately after load_program(0)
RESET: {
    .label sc = $1f
    .label msg = $1d
    lda #$14
    sta VIC_MEMORY
    ldx #' '
    lda #<SCREEN
    sta.z memset.str
    lda #>SCREEN
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    ldx #WHITE
    lda #<COLS
    sta.z memset.str
    lda #>COLS
    sta.z memset.str+1
    lda #<$28*$19
    sta.z memset.num
    lda #>$28*$19
    sta.z memset.num+1
    jsr memset
    lda #<SCREEN+$28
    sta.z sc
    lda #>SCREEN+$28
    sta.z sc+1
    lda #<MESSAGE
    sta.z msg
    lda #>MESSAGE
    sta.z msg+1
  __b1:
    ldy #0
    lda (msg),y
    cmp #0
    bne __b2
    lda #<SCREEN
    sta.z current_screen_line
    lda #>SCREEN
    sta.z current_screen_line+1
    jsr print_newline
    jsr print_newline
    jsr print_newline
    lda #<name
    sta.z initialise_pdb.name
    lda #>name
    sta.z initialise_pdb.name+1
    lda #0
    sta.z initialise_pdb.pdb_number
    jsr initialise_pdb
    lda #0
    jsr load_program
    lda #0
    sta.z resume_pdb.pdb_number
    jsr resume_pdb
  __b4:
    lda #$36
    cmp RASTER
    beq __b5
    lda #$42
    cmp RASTER
    beq __b5
    lda #BLACK
    sta BGCOL
    jmp __b4
  __b5:
    lda #WHITE
    sta BGCOL
    jmp __b4
  __b2:
    ldy #0
    lda (msg),y
    sta (sc),y
    inc.z sc
    bne !+
    inc.z sc+1
  !:
    inc.z msg
    bne !+
    inc.z msg+1
  !:
    jmp __b1
  .segment Data
    name: .text "program3.prg"
    .byte 0
}
.segment Code
// resume_pdb(byte zeropage(2) pdb_number)
resume_pdb: {
    .label __1 = $49
    .label __2 = $49
    .label __7 = $4b
    .label p = $49
    .label ss = $4f
    .label i = 3
    .label pdb_number = 2
    .label __17 = $51
    .label __18 = $53
    lda.z pdb_number
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (p),y
    sta.z dma_copy.src
    iny
    lda (p),y
    sta.z dma_copy.src+1
    iny
    lda (p),y
    sta.z dma_copy.src+2
    iny
    lda (p),y
    sta.z dma_copy.src+3
    lda #0
    sta.z dma_copy.dest
    sta.z dma_copy.dest+1
    sta.z dma_copy.dest+2
    sta.z dma_copy.dest+3
    lda #<$400
    sta.z dma_copy.length
    lda #>$400
    sta.z dma_copy.length+1
    jsr dma_copy
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (p),y
    sta.z __7
    iny
    lda (p),y
    sta.z __7+1
    iny
    lda (p),y
    sta.z __7+2
    iny
    lda (p),y
    sta.z __7+3
    lda.z __7
    clc
    adc #<$800
    sta.z dma_copy.src
    lda.z __7+1
    adc #>$800
    sta.z dma_copy.src+1
    lda.z __7+2
    adc #0
    sta.z dma_copy.src+2
    lda.z __7+3
    adc #0
    sta.z dma_copy.src+3
    lda #<$800
    sta.z dma_copy.dest
    lda #>$800
    sta.z dma_copy.dest+1
    lda #<$800>>$10
    sta.z dma_copy.dest+2
    lda #>$800>>$10
    sta.z dma_copy.dest+3
    lda #<$1800
    sta.z dma_copy.length
    lda #>$1800
    sta.z dma_copy.length+1
    jsr dma_copy
    // Load stored CPU state into Hypervisor saved register area at $FFD3640
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda (p),y
    sta.z ss
    iny
    lda (p),y
    sta.z ss+1
    lda #<0
    sta.z i
    sta.z i+1
  //XXX - Use a for() loop to copy 63 bytes from ss[0]--ss[62] to ((unsigned char *)$D640)[0]
  //      -- ((unsigned char *)$D640)[62] (dma_copy doesn't work for this for some slightly
  //      complex reasons.)
  __b1:
    lda.z i+1
    bmi __b2
    cmp #>$3f
    bcc __b2
    bne !+
    lda.z i
    cmp #<$3f
    bcc __b2
  !:
    // Set state of process to running
    // XXX - Set p->process_state to STATE_RUNNING
    lda #STATE_RUNNING
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    sta (p),y
    // Mark this PDB as the running process
    //XXX - Set running_pdb to the PDB number we are resuming
    lda.z pdb_number
    sta.z running_pdb
    jsr exit_hypervisor
    rts
  __b2:
    lda.z ss
    clc
    adc.z i
    sta.z __17
    lda.z ss+1
    adc.z i+1
    sta.z __17+1
    lda #<$d640
    clc
    adc.z i
    sta.z __18
    lda #>$d640
    adc.z i+1
    sta.z __18+1
    ldy #0
    lda (__17),y
    sta (__18),y
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b1
}
exit_hypervisor: {
    // Exit hypervisor
    lda #1
    sta $d67f
    rts
}
// dma_copy(dword zeropage($b) src, dword zeropage(7) dest, word zeropage(5) length)
dma_copy: {
    .label __0 = $55
    .label __2 = $59
    .label __4 = $5d
    .label __5 = $5f
    .label __7 = $63
    .label __9 = $67
    .label src = $b
    .label dest = 7
    .label list_request_format0a = $31
    .label list_source_mb_option80 = $32
    .label list_source_mb = $33
    .label list_dest_mb_option81 = $34
    .label list_dest_mb = $35
    .label list_end_of_options00 = $36
    .label list_cmd = $37
    .label list_size = $38
    .label list_source_addr = $3a
    .label list_source_bank = $3c
    .label list_dest_addr = $3d
    .label list_dest_bank = $3f
    .label list_modulo00 = $40
    .label length = 5
    lda #0
    sta.z list_request_format0a
    sta.z list_source_mb_option80
    sta.z list_source_mb
    sta.z list_dest_mb_option81
    sta.z list_dest_mb
    sta.z list_end_of_options00
    sta.z list_cmd
    sta.z list_size
    sta.z list_size+1
    sta.z list_source_addr
    sta.z list_source_addr+1
    sta.z list_source_bank
    sta.z list_dest_addr
    sta.z list_dest_addr+1
    sta.z list_dest_bank
    sta.z list_modulo00
    lda #$a
    sta.z list_request_format0a
    lda #$80
    sta.z list_source_mb_option80
    lda #$81
    sta.z list_dest_mb_option81
    lda #0
    sta.z list_end_of_options00
    sta.z list_cmd
    sta.z list_modulo00
    lda.z length
    sta.z list_size
    lda.z length+1
    sta.z list_size+1
    ldx #$14
    lda.z dest
    sta.z __0
    lda.z dest+1
    sta.z __0+1
    lda.z dest+2
    sta.z __0+2
    lda.z dest+3
    sta.z __0+3
    cpx #0
    beq !e+
  !:
    lsr.z __0+3
    ror.z __0+2
    ror.z __0+1
    ror.z __0
    dex
    bne !-
  !e:
    lda.z __0
    sta.z list_dest_mb
    lda #0
    sta.z __2+2
    sta.z __2+3
    lda.z dest+3
    sta.z __2+1
    lda.z dest+2
    sta.z __2
    lda #$7f
    and.z __2
    sta.z list_dest_bank
    lda.z dest
    sta.z __4
    lda.z dest+1
    sta.z __4+1
    lda.z __4
    sta.z list_dest_addr
    lda.z __4+1
    sta.z list_dest_addr+1
    ldx #$14
    lda.z src
    sta.z __5
    lda.z src+1
    sta.z __5+1
    lda.z src+2
    sta.z __5+2
    lda.z src+3
    sta.z __5+3
    cpx #0
    beq !e+
  !:
    lsr.z __5+3
    ror.z __5+2
    ror.z __5+1
    ror.z __5
    dex
    bne !-
  !e:
    lda.z __5
    // Work around missing fragments in KickC
    sta.z list_source_mb
    lda #0
    sta.z __7+2
    sta.z __7+3
    lda.z src+3
    sta.z __7+1
    lda.z src+2
    sta.z __7
    lda #$7f
    and.z __7
    sta.z list_source_bank
    lda.z src
    sta.z __9
    lda.z src+1
    sta.z __9+1
    lda.z __9
    sta.z list_source_addr
    lda.z __9+1
    sta.z list_source_addr+1
    // DMA list lives in hypervisor memory, so use correct list address
    // when triggering
    // (Variables in KickC usually end up in ZP, so we have to provide the
    // base page correction
    lda #0
    cmp #>list_request_format0a
    beq __b1
    lda #>list_request_format0a
    sta $d701
  __b2:
    lda #$7f
    sta $d702
    lda #$ff
    sta $d704
    lda #<list_request_format0a
    sta $d705
    rts
  __b1:
    lda #$bf+(>list_request_format0a)
    sta $d701
    jmp __b2
}
// load_program(byte register(A) pdb_number)
load_program: {
    .label __1 = $69
    .label __2 = $69
    .label __30 = $73
    .label __31 = $73
    .label __34 = $f
    .label __35 = $f
    .label pdb = $69
    .label n = $77
    .label i = $14
    .label new_address = $6f
    .label address = $f
    .label length = $45
    .label dest = $6b
    .label match = $13
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z pdb
    adc #<stored_pdbs
    sta.z pdb
    lda.z pdb+1
    adc #>stored_pdbs
    sta.z pdb+1
    lda #0
    sta.z match
    lda #<$20000
    sta.z address
    lda #>$20000
    sta.z address+1
    lda #<$20000>>$10
    sta.z address+2
    lda #>$20000>>$10
    sta.z address+3
  __b1:
    lda.z address
    sta.z lpeek.address
    lda.z address+1
    sta.z lpeek.address+1
    lda.z address+2
    sta.z lpeek.address+2
    lda.z address+3
    sta.z lpeek.address+3
    jsr lpeek
    txa
    cmp #0
    bne b1
    rts
  // Check for name match
  b1:
    lda #0
    sta.z i
  __b2:
    lda.z i
    cmp #$10
    bcs !__b3+
    jmp __b3
  !__b3:
    jmp __b5
  b3:
    lda #1
    sta.z match
  __b5:
    lda #0
    cmp.z match
    bne !__b8+
    jmp __b8
  !__b8:
    // Found program -- now copy it into place
    sta.z length
    sta.z length+1
    lda #$10
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z length
    lda #0
    sta.z length+1
    lda #$11
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    stx length+1
    // Copy program into place.
    // As the program is formatted as a C64 program with a 
    // $0801 header, we copy it to offset $07FF.
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (pdb),y
    sta.z dest
    iny
    lda (pdb),y
    sta.z dest+1
    iny
    lda (pdb),y
    sta.z dest+2
    iny
    lda (pdb),y
    sta.z dest+3
    lda.z dest
    clc
    adc #<$7ff
    sta.z dest
    lda.z dest+1
    adc #>$7ff
    sta.z dest+1
    lda.z dest+2
    adc #0
    sta.z dest+2
    lda.z dest+3
    adc #0
    sta.z dest+3
    lda #$20
    clc
    adc.z address
    sta.z dma_copy.src
    lda.z address+1
    adc #0
    sta.z dma_copy.src+1
    lda.z address+2
    adc #0
    sta.z dma_copy.src+2
    lda.z address+3
    adc #0
    sta.z dma_copy.src+3
    lda.z dest
    sta.z dma_copy.dest
    lda.z dest+1
    sta.z dma_copy.dest+1
    lda.z dest+2
    sta.z dma_copy.dest+2
    lda.z dest+3
    sta.z dma_copy.dest+3
    lda.z length
    sta.z dma_copy.length
    txa
    sta.z dma_copy.length+1
    jsr dma_copy
    // Mark process as now runnable
    lda #STATE_READY
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    sta (pdb),y
    rts
  __b8:
    lda #$12
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z new_address
    lda #0
    sta.z new_address+1
    sta.z new_address+2
    sta.z new_address+3
    lda #$13
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z __30
    lda #0
    sta.z __30+1
    sta.z __30+2
    sta.z __30+3
    lda.z __31+2
    sta.z __31+3
    lda.z __31+1
    sta.z __31+2
    lda.z __31
    sta.z __31+1
    lda #0
    sta.z __31
    ora.z new_address
    sta.z new_address
    lda.z __31+1
    ora.z new_address+1
    sta.z new_address+1
    lda.z __31+2
    ora.z new_address+2
    sta.z new_address+2
    lda.z __31+3
    ora.z new_address+3
    sta.z new_address+3
    lda #$14
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    txa
    sta.z __34
    lda #0
    sta.z __34+1
    sta.z __34+2
    sta.z __34+3
    lda.z __35+1
    sta.z __35+3
    lda.z __35
    sta.z __35+2
    lda #0
    sta.z __35
    sta.z __35+1
    lda.z new_address
    ora.z address
    sta.z address
    lda.z new_address+1
    ora.z address+1
    sta.z address+1
    lda.z new_address+2
    ora.z address+2
    sta.z address+2
    lda.z new_address+3
    ora.z address+3
    sta.z address+3
    jmp __b1
  __b3:
    lda.z i
    clc
    adc.z address
    sta.z lpeek.address
    lda.z address+1
    adc #0
    sta.z lpeek.address+1
    lda.z address+2
    adc #0
    sta.z lpeek.address+2
    lda.z address+3
    adc #0
    sta.z lpeek.address+3
    jsr lpeek
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda (pdb),y
    sta.z n
    iny
    lda (pdb),y
    sta.z n+1
    ldy.z i
    lda (n),y
    cpx #0
    bne __b4
    cmp #0
    bne !b3+
    jmp b3
  !b3:
  __b4:
    tay
    sty.z $ff
    cpx.z $ff
    beq __b6
    jmp __b5
  __b6:
    inc.z i
    jmp __b2
}
// lpeek(dword zeropage($6b) address)
lpeek: {
    .label t = $41
    .label address = $6b
    // Work around all sorts of fun problems in KickC
    //  dma_copy(address,$BF00+((unsigned short)<&lpeek_value),1);  
    lda #<lpeek_value
    sta.z t
    lda #>lpeek_value
    sta.z t+1
    lda #<lpeek_value>>$10
    sta.z t+2
    lda #>lpeek_value>>$10
    sta.z t+3
    lda #0
    cmp #>lpeek_value
    bne __b1
    lda.z t
    clc
    adc #<$fffbf00
    sta.z t
    lda.z t+1
    adc #>$fffbf00
    sta.z t+1
    lda.z t+2
    adc #<$fffbf00>>$10
    sta.z t+2
    lda.z t+3
    adc #>$fffbf00>>$10
    sta.z t+3
  __b2:
    lda.z address
    sta.z dma_copy.src
    lda.z address+1
    sta.z dma_copy.src+1
    lda.z address+2
    sta.z dma_copy.src+2
    lda.z address+3
    sta.z dma_copy.src+3
    lda.z t
    sta.z dma_copy.dest
    lda.z t+1
    sta.z dma_copy.dest+1
    lda.z t+2
    sta.z dma_copy.dest+2
    lda.z t+3
    sta.z dma_copy.dest+3
    lda #<1
    sta.z dma_copy.length
    lda #>1
    sta.z dma_copy.length+1
    jsr dma_copy
    ldx.z lpeek_value
    rts
  __b1:
    lda.z t
    clc
    adc #<$fff0000
    sta.z t
    lda.z t+1
    adc #>$fff0000
    sta.z t+1
    lda.z t+2
    adc #<$fff0000>>$10
    sta.z t+2
    lda.z t+3
    adc #>$fff0000>>$10
    sta.z t+3
    jmp __b2
}
// Setup a new process descriptor block
// initialise_pdb(byte zeropage($15) pdb_number, byte* zeropage($16) name)
initialise_pdb: {
    .label __1 = $79
    .label __2 = $79
    .label __9 = $7b
    .label __10 = $7b
    .label __11 = $7b
    .label __12 = $7f
    .label __13 = $7f
    .label __14 = $7f
    .label __15 = $83
    .label __16 = $83
    .label __17 = $83
    .label p = $79
    .label pn = $89
    .label i1 = $19
    .label ss = $79
    .label pdb_number = $15
    .label name = $16
    .label __32 = $85
    .label __33 = $87
    lda.z pdb_number
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    jsr next_free_pid
    lda.z next_free_pid.pid
    ldy #0
    sta (p),y
    lda #<process_names
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    sta (p),y
    iny
    lda #>process_names
    sta (p),y
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda (p),y
    sta.z pn
    iny
    lda (p),y
    sta.z pn+1
    lda #<0
    sta.z i1
    sta.z i1+1
  __b1:
    lda.z i1+1
    bpl !__b2+
    jmp __b2
  !__b2:
    cmp #>$11
    bcs !__b2+
    jmp __b2
  !__b2:
    bne !+
    lda.z i1
    cmp #<$11
    bcs !__b2+
    jmp __b2
  !__b2:
  !:
    lda #STATE_NOTRUNNING
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    sta (p),y
    lda.z pdb_number
    sta.z __9
    lda #0
    sta.z __9+1
    sta.z __9+2
    sta.z __9+3
    ldx #$d
    cpx #0
    beq !e+
  !:
    asl.z __10
    rol.z __10+1
    rol.z __10+2
    rol.z __10+3
    dex
    bne !-
  !e:
    lda.z __11
    clc
    adc #<$30000
    sta.z __11
    lda.z __11+1
    adc #>$30000
    sta.z __11+1
    lda.z __11+2
    adc #<$30000>>$10
    sta.z __11+2
    lda.z __11+3
    adc #>$30000>>$10
    sta.z __11+3
    lda.z __11
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    sta (p),y
    iny
    lda.z __11+1
    sta (p),y
    iny
    lda.z __11+2
    sta (p),y
    iny
    lda.z __11+3
    sta (p),y
    lda.z pdb_number
    sta.z __12
    lda #0
    sta.z __12+1
    sta.z __12+2
    sta.z __12+3
    ldx #$d
    cpx #0
    beq !e+
  !:
    asl.z __13
    rol.z __13+1
    rol.z __13+2
    rol.z __13+3
    dex
    bne !-
  !e:
    lda.z __14
    clc
    adc #<$31fff
    sta.z __14
    lda.z __14+1
    adc #>$31fff
    sta.z __14+1
    lda.z __14+2
    adc #<$31fff>>$10
    sta.z __14+2
    lda.z __14+3
    adc #>$31fff>>$10
    sta.z __14+3
    lda.z __14
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS
    sta (p),y
    iny
    lda.z __14+1
    sta (p),y
    iny
    lda.z __14+2
    sta (p),y
    iny
    lda.z __14+3
    sta (p),y
    lda.z pdb_number
    sta.z __15
    lda #0
    sta.z __15+1
    asl.z __16
    rol.z __16+1
    asl.z __16
    rol.z __16+1
    asl.z __16
    rol.z __16+1
    asl.z __16
    rol.z __16+1
    asl.z __16
    rol.z __16+1
    asl.z __16
    rol.z __16+1
    clc
    lda.z __17
    adc #<process_context_states
    sta.z __17
    lda.z __17+1
    adc #>process_context_states
    sta.z __17+1
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda.z __17
    sta (p),y
    iny
    lda.z __17+1
    sta (p),y
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda (ss),y
    pha
    iny
    lda (ss),y
    sta.z ss+1
    pla
    sta.z ss
    ldy #0
  __b4:
    cpy #$3f
    bcc __b5
    lda #$24
    ldy #7
    sta (ss),y
    ldy #5
    lda #<$1ff
    sta (ss),y
    iny
    lda #>$1ff
    sta (ss),y
    ldy #8
    lda #<$80d
    sta (ss),y
    iny
    lda #>$80d
    sta (ss),y
    rts
  __b5:
    lda #0
    sta (ss),y
    iny
    jmp __b4
  __b2:
    lda.z name
    clc
    adc.z i1
    sta.z __32
    lda.z name+1
    adc.z i1+1
    sta.z __32+1
    lda.z pn
    clc
    adc.z i1
    sta.z __33
    lda.z pn+1
    adc.z i1+1
    sta.z __33+1
    ldy #0
    lda (__32),y
    sta (__33),y
    inc.z i1
    bne !+
    inc.z i1+1
  !:
    jmp __b1
}
next_free_pid: {
    .label __2 = $89
    .label pid = $18
    .label p = $89
    .label i = $19
    inc.z pid_counter
    // Start with the next process ID
    lda.z pid_counter
    sta.z pid
    ldx #1
  __b1:
    cpx #0
    bne b1
    rts
  b1:
    ldx #0
    txa
    sta.z i
    sta.z i+1
  __b2:
    lda.z i+1
    cmp #>8
    bcc __b3
    bne !+
    lda.z i
    cmp #<8
    bcc __b3
  !:
    jmp __b1
  __b3:
    lda.z i
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #0
    lda (p),y
    cmp.z pid
    bne __b4
    inc.z pid
    ldx #1
  __b4:
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b2
}
print_newline: {
    lda #$28
    clc
    adc.z current_screen_line
    sta.z current_screen_line
    bcc !+
    inc.z current_screen_line+1
  !:
    lda #0
    sta.z current_screen_x
    rts
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// memset(void* zeropage($1f) str, byte register(X) c, word zeropage($1d) num)
memset: {
    .label end = $1d
    .label dst = $1f
    .label num = $1d
    .label str = $1f
    lda.z num
    bne !+
    lda.z num+1
    beq __breturn
  !:
    lda.z end
    clc
    adc.z str
    sta.z end
    lda.z end+1
    adc.z str+1
    sta.z end+1
  __b2:
    lda.z dst+1
    cmp.z end+1
    bne __b3
    lda.z dst
    cmp.z end
    bne __b3
  __breturn:
    rts
  __b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp __b2
}
syscall3F: {
    jsr exit_hypervisor
    rts
}
syscall3E: {
    jsr exit_hypervisor
    rts
}
syscall3D: {
    jsr exit_hypervisor
    rts
}
syscall3C: {
    jsr exit_hypervisor
    rts
}
syscall3B: {
    jsr exit_hypervisor
    rts
}
syscall3A: {
    jsr exit_hypervisor
    rts
}
syscall39: {
    jsr exit_hypervisor
    rts
}
syscall38: {
    jsr exit_hypervisor
    rts
}
syscall37: {
    jsr exit_hypervisor
    rts
}
syscall36: {
    jsr exit_hypervisor
    rts
}
syscall35: {
    jsr exit_hypervisor
    rts
}
syscall34: {
    jsr exit_hypervisor
    rts
}
syscall33: {
    jsr exit_hypervisor
    rts
}
syscall32: {
    jsr exit_hypervisor
    rts
}
syscall31: {
    jsr exit_hypervisor
    rts
}
syscall30: {
    jsr exit_hypervisor
    rts
}
syscall2F: {
    jsr exit_hypervisor
    rts
}
syscall2E: {
    jsr exit_hypervisor
    rts
}
syscall2D: {
    jsr exit_hypervisor
    rts
}
syscall2C: {
    jsr exit_hypervisor
    rts
}
syscall2B: {
    jsr exit_hypervisor
    rts
}
syscall2A: {
    jsr exit_hypervisor
    rts
}
syscall29: {
    jsr exit_hypervisor
    rts
}
syscall28: {
    jsr exit_hypervisor
    rts
}
syscall27: {
    jsr exit_hypervisor
    rts
}
syscall26: {
    jsr exit_hypervisor
    rts
}
syscall25: {
    jsr exit_hypervisor
    rts
}
syscall23: {
    jsr exit_hypervisor
    rts
}
syscall22: {
    jsr exit_hypervisor
    rts
}
syscall21: {
    jsr exit_hypervisor
    rts
}
syscall20: {
    jsr exit_hypervisor
    rts
}
syscall1F: {
    jsr exit_hypervisor
    rts
}
syscall1E: {
    jsr exit_hypervisor
    rts
}
syscall1D: {
    jsr exit_hypervisor
    rts
}
syscall1C: {
    jsr exit_hypervisor
    rts
}
syscall1B: {
    jsr exit_hypervisor
    rts
}
syscall1A: {
    jsr exit_hypervisor
    rts
}
syscall19: {
    jsr exit_hypervisor
    rts
}
syscall18: {
    jsr exit_hypervisor
    rts
}
syscall17: {
    jsr exit_hypervisor
    rts
}
syscall16: {
    jsr exit_hypervisor
    rts
}
syscall15: {
    jsr exit_hypervisor
    rts
}
syscall14: {
    jsr exit_hypervisor
    rts
}
syscall13: {
    jsr exit_hypervisor
    rts
}
SECUREXIT: {
    jsr exit_hypervisor
    rts
}
SECURENTR: {
    jsr exit_hypervisor
    rts
}
syscall10: {
    jsr exit_hypervisor
    rts
}
syscall0F: {
    jsr exit_hypervisor
    rts
}
syscall0E: {
    jsr exit_hypervisor
    rts
}
syscall0D: {
    jsr exit_hypervisor
    rts
}
syscall0C: {
    jsr exit_hypervisor
    rts
}
syscall0B: {
    jsr exit_hypervisor
    rts
}
syscall0A: {
    jsr exit_hypervisor
    rts
}
syscall09: {
    jsr exit_hypervisor
    rts
}
syscall08: {
    .label __1 = $8b
    .label __2 = $8b
    .label pdb = $8b
    .label p_name = $23
    .label o_name = $21
    .label ss = $8b
    lda.z running_pdb
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z pdb
    adc #<stored_pdbs
    sta.z pdb
    lda.z pdb+1
    adc #>stored_pdbs
    sta.z pdb+1
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda (pdb),y
    sta.z p_name
    iny
    lda (pdb),y
    sta.z p_name+1
    lda #<$300
    sta.z o_name
    lda #>$300
    sta.z o_name+1
  __b1:
    ldy #0
    lda (o_name),y
    cmp #0
    bne __b2
    tya
    tay
    sta (p_name),y
    lda.z running_pdb
    jsr load_program
    // set-up new program
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda (ss),y
    pha
    iny
    lda (ss),y
    sta.z ss+1
    pla
    sta.z ss
    ldy #0
  __b4:
    cpy #$3f
    bcc __b5
    lda #$24
    ldy #7
    sta (ss),y
    ldy #5
    lda #<$1ff
    sta (ss),y
    iny
    lda #>$1ff
    sta (ss),y
    ldy #8
    lda #<$80d
    sta (ss),y
    iny
    lda #>$80d
    sta (ss),y
    lda.z running_pdb
    sta.z resume_pdb.pdb_number
    jsr resume_pdb
    rts
  __b5:
    lda #0
    sta (ss),y
    iny
    jmp __b4
  __b2:
    ldy #0
    lda (o_name),y
    sta (p_name),y
    inc.z p_name
    bne !+
    inc.z p_name+1
  !:
    inc.z o_name
    bne !+
    inc.z o_name+1
  !:
    jmp __b1
}
syscall07: {
    .label __5 = $90
    .label __6 = $90
    .label __13 = $8e
    .label __14 = $8e
    .label parent_pdb = $8d
    .label pdb = $8e
    .label i = $25
    .label p = $90
    .label child_pdb = $25
    lda.z running_pdb
    sta.z parent_pdb
    lda.z running_pdb
    jsr pause_pdb
    lda #0
    sta.z i
  __b1:
    lda.z i
    cmp #8
    bcc __b2
    lda #0
    sta.z child_pdb
    jmp __b4
  __b2:
    lda.z i
    sta.z __13
    lda #0
    sta.z __13+1
    lda.z __14
    sta.z __14+1
    lda #0
    sta.z __14
    clc
    lda.z pdb
    adc #<stored_pdbs
    sta.z pdb
    lda.z pdb+1
    adc #>stored_pdbs
    sta.z pdb+1
    ldy #0
    lda (pdb),y
    cmp #0
    bne __b3
  __b4:
    lda.z child_pdb
    sta.z initialise_pdb.pdb_number
    lda #<name
    sta.z initialise_pdb.name
    lda #>name
    sta.z initialise_pdb.name+1
    jsr initialise_pdb
    lda #0
    sta $300
    lda.z child_pdb
    jsr pause_pdb
    lda.z child_pdb
    sta.z __5
    lda #0
    sta.z __5+1
    lda.z __6
    sta.z __6+1
    lda #0
    sta.z __6
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #0
    lda (p),y
    sta $300
    lda.z parent_pdb
    sta.z running_pdb
    jsr exit_hypervisor
    rts
  __b3:
    inc.z i
    jmp __b1
  .segment Data
    name: .text "temp_child"
    .byte 0
}
.segment Code
// pause_pdb(byte register(A) pdb_number)
pause_pdb: {
    .label __1 = $92
    .label __2 = $92
    .label __7 = $94
    .label p = $92
    .label ss = $98
    .label i = $26
    .label __16 = $9a
    .label __17 = $9c
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (p),y
    sta.z dma_copy.dest
    iny
    lda (p),y
    sta.z dma_copy.dest+1
    iny
    lda (p),y
    sta.z dma_copy.dest+2
    iny
    lda (p),y
    sta.z dma_copy.dest+3
    lda #0
    sta.z dma_copy.src
    sta.z dma_copy.src+1
    sta.z dma_copy.src+2
    sta.z dma_copy.src+3
    lda #<$400
    sta.z dma_copy.length
    lda #>$400
    sta.z dma_copy.length+1
    jsr dma_copy
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (p),y
    sta.z __7
    iny
    lda (p),y
    sta.z __7+1
    iny
    lda (p),y
    sta.z __7+2
    iny
    lda (p),y
    sta.z __7+3
    lda.z __7
    clc
    adc #<$800
    sta.z dma_copy.dest
    lda.z __7+1
    adc #>$800
    sta.z dma_copy.dest+1
    lda.z __7+2
    adc #0
    sta.z dma_copy.dest+2
    lda.z __7+3
    adc #0
    sta.z dma_copy.dest+3
    lda #<$800
    sta.z dma_copy.src
    lda #>$800
    sta.z dma_copy.src+1
    lda #<$800>>$10
    sta.z dma_copy.src+2
    lda #>$800>>$10
    sta.z dma_copy.src+3
    lda #<$1800
    sta.z dma_copy.length
    lda #>$1800
    sta.z dma_copy.length+1
    jsr dma_copy
    // Load stored CPU state into Hypervisor saved register area at $FFD3640
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda (p),y
    sta.z ss
    iny
    lda (p),y
    sta.z ss+1
    lda #<0
    sta.z i
    sta.z i+1
  //XXX - Use a for() loop to copy 63 bytes from ss[0]--ss[62] to ((unsigned char *)$D640)[0]
  //      -- ((unsigned char *)$D640)[62] (dma_copy doesn't work for this for some slightly
  //      complex reasons.)
  __b1:
    lda.z i+1
    bmi __b2
    cmp #>$3f
    bcc __b2
    bne !+
    lda.z i
    cmp #<$3f
    bcc __b2
  !:
    // Set state of process to running
    // XXX - Set p->process_state to STATE_RUNNING
    lda #STATE_READY
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    sta (p),y
    // Mark this PDB as the running process
    //XXX - Set running_pdb to the PDB number we are resuming
    lda #0
    sta.z running_pdb
    rts
  __b2:
    lda #<$d640
    clc
    adc.z i
    sta.z __16
    lda #>$d640
    adc.z i+1
    sta.z __16+1
    lda.z ss
    clc
    adc.z i
    sta.z __17
    lda.z ss+1
    adc.z i+1
    sta.z __17+1
    ldy #0
    lda (__16),y
    sta (__17),y
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b1
}
syscall06: {
    .label __1 = $9e
    .label __2 = $9e
    .label pdb = $9e
    lda.z running_pdb
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z pdb
    adc #<stored_pdbs
    sta.z pdb
    lda.z pdb+1
    adc #>stored_pdbs
    sta.z pdb+1
    lda #<message
    sta.z print_to_screen.c
    lda #>message
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #0
    lda (pdb),y
    sta.z print_hex.value
    tya
    sta.z print_hex.value+1
    jsr print_hex
    lda #<message1
    sta.z print_to_screen.c
    lda #>message1
    sta.z print_to_screen.c+1
    jsr print_to_screen
    lda.z running_pdb
    sta.z print_hex.value
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
    jsr print_newline
    jsr exit_hypervisor
    rts
  .segment Data
    message: .text "you are pid "
    .byte 0
    message1: .text " in pdb "
    .byte 0
}
.segment Code
// print_hex(word zeropage($28) value)
print_hex: {
    .label __3 = $a0
    .label __6 = $a2
    .label value = $28
    ldx #0
  __b1:
    cpx #8
    bcc __b2
    lda #0
    sta hex+4
    lda #<hex
    sta.z print_to_screen.c
    lda #>hex
    sta.z print_to_screen.c+1
    jsr print_to_screen
    rts
  __b2:
    lda.z value+1
    cmp #>$a000
    bcc __b4
    bne !+
    lda.z value
    cmp #<$a000
    bcc __b4
  !:
    ldy #$c
    lda.z value
    sta.z __3
    lda.z value+1
    sta.z __3+1
    cpy #0
    beq !e+
  !:
    lsr.z __3+1
    ror.z __3
    dey
    bne !-
  !e:
    lda.z __3
    sec
    sbc #9
    sta hex,x
  __b5:
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    asl.z value
    rol.z value+1
    inx
    jmp __b1
  __b4:
    ldy #$c
    lda.z value
    sta.z __6
    lda.z value+1
    sta.z __6+1
    cpy #0
    beq !e+
  !:
    lsr.z __6+1
    ror.z __6
    dey
    bne !-
  !e:
    lda.z __6
    clc
    adc #'0'
    sta hex,x
    jmp __b5
  .segment Data
    hex: .fill 5, 0
}
.segment Code
print_to_screen: {
    .label c = $28
  __b1:
    ldy #0
    lda (c),y
    cmp #0
    bne __b2
    rts
  __b2:
    ldy #0
    lda (c),y
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    inc.z c
    bne !+
    inc.z c+1
  !:
    jmp __b1
}
syscall05: {
    .label __9 = $a4
    .label __10 = $a4
    .label next_pdb = $2b
    .label pdb = $a4
    lda.z running_pdb
    sta.z next_pdb
    cmp #8
    bcs __b1
    lda.z running_pdb
    jsr pause_pdb
  __b1:
    ldx #0
  __b3:
    cpx #8
    bcc __b4
  __b7:
    lda.z next_pdb
    sta.z resume_pdb.pdb_number
    jsr resume_pdb
    jsr exit_hypervisor
    rts
  __b4:
    cpx.z next_pdb
    bne __b5
  __b6:
    inx
    jmp __b3
  __b5:
    txa
    sta.z __9
    lda #0
    sta.z __9+1
    lda.z __10
    sta.z __10+1
    lda #0
    sta.z __10
    clc
    lda.z pdb
    adc #<stored_pdbs
    sta.z pdb
    lda.z pdb+1
    adc #>stored_pdbs
    sta.z pdb+1
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    lda (pdb),y
    cmp #STATE_READY
    bne __b6
    stx.z next_pdb
    jmp __b7
}
syscall04: {
    jsr exit_hypervisor
    rts
}
syscall03: {
    ldx.z running_pdb
    jsr describe_pdb
    jsr exit_hypervisor
    rts
}
// describe_pdb(byte register(X) pdb_number)
describe_pdb: {
    .label __1 = $a6
    .label __2 = $a6
    .label p = $a6
    .label n = $a8
    .label ss = $a6
    txa
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z __2
    sta.z __2+1
    lda #0
    sta.z __2
    clc
    lda.z p
    adc #<stored_pdbs
    sta.z p
    lda.z p+1
    adc #>stored_pdbs
    sta.z p+1
    lda #<message
    sta.z print_to_screen.c
    lda #>message
    sta.z print_to_screen.c+1
    jsr print_to_screen
    txa
    sta.z print_hex.value
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
    lda #<message1
    sta.z print_to_screen.c
    lda #>message1
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jsr print_newline
    lda #<message2
    sta.z print_to_screen.c
    lda #>message2
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #0
    lda (p),y
    sta.z print_hex.value
    iny
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
    jsr print_newline
    lda #<message3
    sta.z print_to_screen.c
    lda #>message3
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_STATE
    lda (p),y
    cmp #STATE_NEW
    bne !__b7+
    jmp __b7
  !__b7:
    lda (p),y
    cmp #STATE_RUNNING
    bne !__b8+
    jmp __b8
  !__b8:
    lda (p),y
    cmp #STATE_BLOCKED
    bne !__b9+
    jmp __b9
  !__b9:
    lda (p),y
    cmp #STATE_READY
    bne !__b10+
    jmp __b10
  !__b10:
    lda (p),y
    cmp #STATE_BLOCKEDSUSPENDED
    bne !__b11+
    jmp __b11
  !__b11:
    lda (p),y
    cmp #STATE_READYSUSPENDED
    bne !__b12+
    jmp __b12
  !__b12:
    lda (p),y
    cmp #STATE_EXIT
    bne !__b13+
    jmp __b13
  !__b13:
    lda (p),y
    sta.z print_hex.value
    iny
    lda #0
    sta.z print_hex.value+1
    jsr print_hex
  __b15:
    jsr print_newline
    lda #<message11
    sta.z print_to_screen.c
    lda #>message11
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_PROCESS_NAME
    lda (p),y
    sta.z n
    iny
    lda (p),y
    sta.z n+1
    ldx #0
  __b16:
    txa
    tay
    lda (n),y
    cmp #0
    bne __b17
    jsr print_newline
    lda #<message12
    sta.z print_to_screen.c
    lda #>message12
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_START_ADDRESS
    lda (p),y
    sta.z print_dhex.value
    iny
    lda (p),y
    sta.z print_dhex.value+1
    iny
    lda (p),y
    sta.z print_dhex.value+2
    iny
    lda (p),y
    sta.z print_dhex.value+3
    jsr print_dhex
    jsr print_newline
    lda #<message13
    sta.z print_to_screen.c
    lda #>message13
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORAGE_END_ADDRESS
    lda (p),y
    sta.z print_dhex.value
    iny
    lda (p),y
    sta.z print_dhex.value+1
    iny
    lda (p),y
    sta.z print_dhex.value+2
    iny
    lda (p),y
    sta.z print_dhex.value+3
    jsr print_dhex
    jsr print_newline
    lda #<message14
    sta.z print_to_screen.c
    lda #>message14
    sta.z print_to_screen.c+1
    jsr print_to_screen
    ldy #OFFSET_STRUCT_PROCESS_DESCRIPTOR_BLOCK_STORED_STATE
    lda (ss),y
    pha
    iny
    lda (ss),y
    sta.z ss+1
    pla
    sta.z ss
    ldy #4*SIZEOF_WORD
    lda (ss),y
    sta.z print_hex.value
    iny
    lda (ss),y
    sta.z print_hex.value+1
    jsr print_hex
    jsr print_newline
    rts
  __b17:
    txa
    tay
    lda (n),y
    jsr print_char
    inx
    jmp __b16
  __b13:
    lda #<message10
    sta.z print_to_screen.c
    lda #>message10
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b12:
    lda #<message9
    sta.z print_to_screen.c
    lda #>message9
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b11:
    lda #<message8
    sta.z print_to_screen.c
    lda #>message8
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b10:
    lda #<message7
    sta.z print_to_screen.c
    lda #>message7
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b9:
    lda #<message6
    sta.z print_to_screen.c
    lda #>message6
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b8:
    lda #<message5
    sta.z print_to_screen.c
    lda #>message5
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  __b7:
    lda #<message4
    sta.z print_to_screen.c
    lda #>message4
    sta.z print_to_screen.c+1
    jsr print_to_screen
    jmp __b15
  .segment Data
    message: .text "pdb#"
    .byte 0
    message1: .text ":"
    .byte 0
    message2: .text "  pid:          "
    .byte 0
    message3: .text "  state:        "
    .byte 0
    message4: .text "new"
    .byte 0
    message5: .text "running"
    .byte 0
    message6: .text "blocked"
    .byte 0
    message7: .text "ready"
    .byte 0
    message8: .text "blockedsuspended"
    .byte 0
    message9: .text "readysuspended"
    .byte 0
    message10: .text "exit"
    .byte 0
    message11: .text "  process name: "
    .byte 0
    message12: .text "  mem start:    $"
    .byte 0
    message13: .text "  mem end:      $"
    .byte 0
    message14: .text "  pc:           $"
    .byte 0
}
.segment Code
// print_char(byte register(A) c)
print_char: {
    ldy.z current_screen_x
    sta (current_screen_line),y
    inc.z current_screen_x
    rts
}
// print_dhex(dword zeropage($2d) value)
print_dhex: {
    .label __0 = $aa
    .label value = $2d
    lda #0
    sta.z __0+2
    sta.z __0+3
    lda.z value+3
    sta.z __0+1
    lda.z value+2
    sta.z __0
    sta.z print_hex.value
    lda.z __0+1
    sta.z print_hex.value+1
    jsr print_hex
    lda.z value
    sta.z print_hex.value
    lda.z value+1
    sta.z print_hex.value+1
    jsr print_hex
    rts
}
syscall02: {
    jsr exit_hypervisor
    rts
}
syscall01: {
    jsr exit_hypervisor
    rts
}
syscall00: {
    jsr exit_hypervisor
    rts
}
.segment Data
  MESSAGE: .text "checkpoint 5.5 gabi0004"
  .byte 0
.segment Syscall
  SYSCALLS: .byte JMP
  .word syscall00
  .byte NOP, JMP
  .word syscall01
  .byte NOP, JMP
  .word syscall02
  .byte NOP, JMP
  .word syscall03
  .byte NOP, JMP
  .word syscall04
  .byte NOP, JMP
  .word syscall05
  .byte NOP, JMP
  .word syscall06
  .byte NOP, JMP
  .word syscall07
  .byte NOP, JMP
  .word syscall08
  .byte NOP, JMP
  .word syscall09
  .byte NOP, JMP
  .word syscall0A
  .byte NOP, JMP
  .word syscall0B
  .byte NOP, JMP
  .word syscall0C
  .byte NOP, JMP
  .word syscall0D
  .byte NOP, JMP
  .word syscall0E
  .byte NOP, JMP
  .word syscall0F
  .byte NOP, JMP
  .word syscall10
  .byte NOP, JMP
  .word syscall13
  .byte NOP, JMP
  .word syscall14
  .byte NOP, JMP
  .word syscall15
  .byte NOP, JMP
  .word syscall16
  .byte NOP, JMP
  .word syscall17
  .byte NOP, JMP
  .word syscall18
  .byte NOP, JMP
  .word syscall19
  .byte NOP, JMP
  .word syscall1A
  .byte NOP, JMP
  .word syscall1B
  .byte NOP, JMP
  .word syscall1C
  .byte NOP, JMP
  .word syscall1D
  .byte NOP, JMP
  .word syscall1E
  .byte NOP, JMP
  .word syscall1F
  .byte NOP, JMP
  .word syscall20
  .byte NOP, JMP
  .word syscall21
  .byte NOP, JMP
  .word syscall22
  .byte NOP, JMP
  .word syscall23
  .byte NOP, JMP
  .word syscall23
  .byte NOP, JMP
  .word syscall25
  .byte NOP, JMP
  .word syscall26
  .byte NOP, JMP
  .word syscall27
  .byte NOP, JMP
  .word syscall28
  .byte NOP, JMP
  .word syscall29
  .byte NOP, JMP
  .word syscall2A
  .byte NOP, JMP
  .word syscall2B
  .byte NOP, JMP
  .word syscall2C
  .byte NOP, JMP
  .word syscall2D
  .byte NOP, JMP
  .word syscall2E
  .byte NOP, JMP
  .word syscall2F
  .byte NOP, JMP
  .word syscall30
  .byte NOP, JMP
  .word syscall31
  .byte NOP, JMP
  .word syscall32
  .byte NOP, JMP
  .word syscall33
  .byte NOP, JMP
  .word syscall34
  .byte NOP, JMP
  .word syscall35
  .byte NOP, JMP
  .word syscall36
  .byte NOP, JMP
  .word syscall37
  .byte NOP, JMP
  .word syscall38
  .byte NOP, JMP
  .word syscall39
  .byte NOP, JMP
  .word syscall3A
  .byte NOP, JMP
  .word syscall3B
  .byte NOP, JMP
  .word syscall3C
  .byte NOP, JMP
  .word syscall3D
  .byte NOP, JMP
  .word syscall3E
  .byte NOP, JMP
  .word syscall3F
  .byte NOP, JMP
  .word SECURENTR
  .byte NOP, JMP
  .word SECUREXIT
  .byte NOP
  .align $100
  TRAPS: .byte JMP
  .word RESET
  .byte NOP, JMP
  .word pagfault
  .byte NOP, JMP
  .word restorkey
  .byte NOP, JMP
  .word alttabkey
  .byte NOP, JMP
  .word vf011rd
  .byte NOP, JMP
  .word vf011wr
  .byte NOP, JMP
  .word reservd
  .byte NOP, JMP
  .word cpukil
  .byte NOP
