; Copyright (c) 2014 Takaaki TSUJIMOTO

[BITS 32]

; オブジェクトファイルのための情報

    GLOBAL io_hlt, io_cli, io_sti, io_stihlt
    GLOBAL io_in8, io_in16, io_in32
    GLOBAL io_out8, io_out16, io_out32
    GLOBAL io_load_eflags, io_store_eflags
    GLOBAL load_gdtr, load_idtr
    GLOBAL load_cr0, store_cr0
    GLOBAL load_tr
    GLOBAL asm_inthandler20, asm_inthandler21
    GLOBAL asm_inthandler27, asm_inthandler2c
    GLOBAL farjmp, farcall
    GLOBAL asm_cons_putchar
    EXTERN inthandler20, inthandler21
    EXTERN inthandler27, inthandler2c
    EXTERN cons_putchar


; 以下は実際の関数

[SECTION .text]  ; オブジェクトファイルではこれを書いてからプログラムを書く

io_hlt:     ; void io_hlt(void);
    HLT
    RET

io_cli:     ; void io_cli(void);
    CLI
    RET

io_sti:     ; void io_sti(void);
    STI
    RET

io_stihlt:  ; void io_stihlt(void);
    STI
    HLT
    RET

io_in8:     ; int io_in8(int port);
    MOV EDX,[ESP+4]     ; port
    MOV EAX,0
    IN  AL,DX
    RET

io_in16:    ; int io_in16(int port);
    MOV EDX,[ESP+4]     ; port
    MOV EAX,0
    IN  AX,DX
    RET

io_in32:    ; int io_in32(int port);
    MOV EDX,[ESP+4]     ; port
    MOV EAX,0
    IN  AX,DX
    RET

io_out8:    ; void io_out8(int port, int data);
    MOV EDX,[ESP+4]     ; port
    MOV EAX,[ESP+8]     ; data
    OUT DX,AL
    RET

io_out16:   ; void io_out16(int port, int data);
    MOV EDX,[ESP+4]     ; port
    MOV EAX,[ESP+8]     ; data
    OUT DX,AX
    RET

io_out32:   ; void io_out8(int port, int data);
    MOV EDX,[ESP+4]     ; port
    MOV EAX,[ESP+8]     ; data
    OUT DX,EAX
    RET

io_load_eflags:     ; int io_load_eflags(void);
    PUSHFD
    POP EAX
    RET

io_store_eflags:    ; void io_store_eflags(int eflags);
    MOV EAX,[ESP+4]
    PUSH EAX
    POPFD
    RET

load_gdtr:     ; void load_gdtr(int limit, int addr);
    MOV     AX,[ESP+4]  ; limit
    MOV     [ESP+6],AX
    LGDT    [ESP+6]
    RET

load_idtr:     ; void load_idtr(int limit, int addr);
    MOV     AX,[ESP+4]  ; limit
    MOV     [ESP+6],AX
    LIDT    [ESP+6]
    RET

load_cr0:   ; int load_cr0(void);
    MOV     EAX,CR0
    RET

store_cr0:  ; void store_cr0(int cr0);
    MOV     EAX,[ESP+4]
    MOV     CR0,EAX
    RET

load_tr:    ; void load_tr(int tr);
    LTR     [ESP+4]     ; tr
    RET

asm_inthandler20:
    PUSH    ES
    PUSH    DS
    PUSHAD
    MOV     EAX,ESP
    PUSH    EAX
    MOV     AX,SS
    MOV     DS,AX
    MOV     ES,AX
    CALL    inthandler20
    POP     EAX
    POPAD
    POP     DS
    POP     ES
    IRETD

asm_inthandler21:
    PUSH    ES
    PUSH    DS
    PUSHAD
    MOV     EAX,ESP
    PUSH    EAX
    MOV     AX,SS
    MOV     DS,AX
    MOV     ES,AX
    CALL    inthandler21
    POP     EAX
    POPAD
    POP     DS
    POP     ES
    IRETD

asm_inthandler27:
    PUSH    ES
    PUSH    DS
    PUSHAD
    MOV     EAX,ESP
    PUSH    EAX
    MOV     AX,SS
    MOV     DS,AX
    MOV     ES,AX
    CALL    inthandler27
    POP     EAX
    POPAD
    POP     DS
    POP     ES
    IRETD

asm_inthandler2c:
    PUSH    ES
    PUSH    DS
    PUSHAD
    MOV     EAX,ESP
    PUSH EAX
    MOV     AX,SS
    MOV     DS,AX
    MOV     ES,AX
    CALL    inthandler2c
    POP     EAX
    POPAD
    POP     DS
    POP     ES
    IRETD

farjmp:        ; void farjmp(int eip, int cs);
    JMP     FAR [ESP+4]     ; eip, cs
    RET

farcall:    ; void farcall(int eip, int cs);
    CALL    FAR [ESP+4] ; eip, cs
    RET

asm_cons_putchar:
    STI
    PUSH    1
    AND     EAX,0xff        ; AHやEAXの上位を0にして、EAXに文字コードが入った状態にする。
    PUSH    EAX
    PUSH    DWORD [0x0fec]  ; メモリの内容を読み込んでその値をPUSHする
    CALL    cons_putchar
    ADD     ESP,12          ; スタックに積んだデータを捨てる
    IRETD

