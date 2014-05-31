// Copyright (c) 2014 Takaaki TSUJIMOTO

/* 他のファイルで作った関数があることをCコンパイラに教える */
void io_hlt(void);
void write_mem8(int addr, int data);

void HariMain(void)
{
    int i;

    for (i = 0xa0000; i <= 0xaffff; i++) {
        write_mem8(i, 10); /* MOV BYTE [i],15 */
    }

    for (;;) {
        io_hlt();
    }
}
