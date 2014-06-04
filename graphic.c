// Copyright (c) 2014 Takaaki TSUJIMOTO
#include "bootpack.h"

void init_palette(void)
{
    static unsigned char table_rgb[16 * 3] = {
        0x00, 0x00, 0x00, /* 0:黒 */
        0xff, 0x00, 0x00, /* 1:明るい赤 */
        0x00, 0xff, 0x00, /* 2:明るい緑 */
        0xff, 0xff, 0x00, /* 3:明るい黄色 */
        0x00, 0x00, 0xff, /* 4:明るい青 */
        0xff, 0x00, 0xff, /* 5:明るい紫 */
        0x00, 0xff, 0xff, /* 6:明るい水色 */
        0xff, 0xff, 0xff, /* 7:白 */
        0xc6, 0xc6, 0xc6, /* 8:明るい灰色 */
        0x84, 0x00, 0x00, /* 9:暗い赤 */
        0x00, 0x84, 0x00, /* 10:暗い緑 */
        0x84, 0x84, 0x00, /* 11:暗い黄色 */
        0x00, 0x00, 0x84, /* 12:暗い青 */
        0x84, 0x00, 0x84, /* 13:暗い紫 */
        0x00, 0x84, 0x84, /* 14:暗い水色 */
        0x84, 0x84, 0x84  /* 15:暗い灰色 */
    };
    set_palette(0, 15, table_rgb);
    return;

    /* static char 命令は、データにしか使えないがDB命令相当 */
}

void set_palette(int start, int end, unsigned char *rgb)
{
    int i, eflags;
    eflags = io_load_eflags(); /* 割り込み許可フラグの値を記録する */
    io_cli();                  /* 許可フラグを0にして割り込み禁止にする */
    io_out8(0x03c8, start);
    for (i = start; i <= end; i++) {
        io_out8(0x03c9, rgb[0] / 4);
        io_out8(0x03c9, rgb[1] / 4);
        io_out8(0x03c9, rgb[2] / 4);
        rgb += 3;
    }
    io_store_eflags(eflags);   /* 割り込み許可フラグを元に戻す */
    return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1)
{
    int x, y;
    for (y = y0; y <= y1; y++) {
        for (x = x0; x <= x1; x++)
            vram[y * xsize + x] = c;
    }
    return;
}

void init_screen(char *vram, int x, int y)
{
    boxfill8(vram, x, COL8_008484,  0,     0,      x -  1, y - 29);
    boxfill8(vram, x, COL8_C6C6C6,  0,     y - 28, x -  1, y - 28);
    boxfill8(vram, x, COL8_FFFFFF,  0,     y - 27, x -  1, y - 27);
    boxfill8(vram, x, COL8_C6C6C6,  0,     y - 26, x -  1, y -  1);

    boxfill8(vram, x, COL8_FFFFFF,  3,     y - 24, 59,     y - 24);
    boxfill8(vram, x, COL8_FFFFFF,  2,     y - 24,  2,     y -  4);
    boxfill8(vram, x, COL8_848484,  3,     y -  4, 59,     y -  4);
    boxfill8(vram, x, COL8_848484, 59,     y - 23, 59,     y -  5);
    boxfill8(vram, x, COL8_000000,  2,     y -  3, 59,     y -  3);
    boxfill8(vram, x, COL8_000000, 60,     y - 24, 60,     y -  3);

    boxfill8(vram, x, COL8_848484, x - 47, y - 24, x -  4, y - 24);
    boxfill8(vram, x, COL8_848484, x - 47, y - 23, x - 47, y -  4);
    boxfill8(vram, x, COL8_FFFFFF, x - 47, y -  3, x -  4, y -  3);
    boxfill8(vram, x, COL8_FFFFFF, x -  3, y - 24, x -  3, y -  3);
    return;
}

void putfont8(char *vram, int xsize, int x, int y, char color, char *font)
{
    int i;
    char *p, d /* data */;
    for (i = 0; i < 16; i++) {
        p = vram + (y + i) * xsize + x;
        d = font[i];
        if ((d & 0x80) != 0) { p[0] = color; }
        if ((d & 0x40) != 0) { p[1] = color; }
        if ((d & 0x20) != 0) { p[2] = color; }
        if ((d & 0x10) != 0) { p[3] = color; }
        if ((d & 0x08) != 0) { p[4] = color; }
        if ((d & 0x04) != 0) { p[5] = color; }
        if ((d & 0x02) != 0) { p[6] = color; }
        if ((d & 0x01) != 0) { p[7] = color; }
    }
    return;
}

void putfonts8_asc(char *vram, int xsize, int x, int y, char color, unsigned char *str)
{
    extern char hankaku[4096];
    for (; *str != 0x00; str++) {
        putfont8(vram, xsize, x, y, color, hankaku + *str * 16);
        x += 8;
    }
    return;
}

int lsprintf(char *str, const char *fmt, ...)
{
    int *arg = (int *)(&str + 2);        // 可変個引数の配列
    int cnt, i, argc = 0;
    char buf[20];
    const char *p = fmt;
    for(cnt = 0; *p != '\0'; p++) {
        if(*p == '%') {
            strcls(buf);        // バッファの初期化
            // フォーマット指定子の場合は引数の数値を文字列へ変換
            switch(p[1]) {
                case 'd': int2dec(buf, arg[argc++]); break;
                case 'x': int2hex(buf, arg[argc++]); break;
            }
            // 変換した数値を生成文字列にコピー
            for(i = 0; buf[i] != '\0'; i++,cnt++) *str++ = buf[i];
            p++;
        } else {
            // フォーマット指定子以外はそのままコピー
            *str++ = *p; cnt++;
        }
    }
    return cnt;
}

// ヌル文字で埋める
void strcls(char *str)
{
    while(*str != '\0') *str++ = '\0';
}

// 数値を16進数文字列に変換する
void int2hex(char *s, int value)
{
    s[0] = '0', s[1] = 'x';
    int i, filter = 0x0000000f;
    s += 2;
    for(i = 0; i < 8; i++) {
        if(((value >> (7-i)*4) & filter) >= 10) {
            *s++ = 'A' + ((value >> (7-i)*4) & filter) - 10;
        } else {
            *s++ = '0' + ((value >> (7-i)*4) & filter);
        }
    }
    *s = '\0';
}

// 10進数valueのn桁目を返す
int figure(int value, int n)
{
    int i;
    for(i = 0; i < n-1; i++) value /= 10;
    return value % 10;
}

// 数値を10進数文字列に変換する
void int2dec(char *s, int value)
{
    int i;
    char zero = 1;
    for(i = 0; i < 10; i++) {
        if(zero && figure(value, 10-i) != 0) zero = 0;
        if(!zero) *s++ = '0' + figure(value, 10-i);
    }
}

void init_mouse_cursor8(char *mouse, char bc)
    /* マウスカーソルを準備（16x16） */
{
    static char cursor[16][16] = {
        "**************..",
        "*OOOOOOOOOOO*...",
        "*OOOOOOOOOO*....",
        "*OOOOOOOOO*.....",
        "*OOOOOOOO*......",
        "*OOOOOOO*.......",
        "*OOOOOOO*.......",
        "*OOOOOOOO*......",
        "*OOOO**OOO*.....",
        "*OOO*..*OOO*....",
        "*OO*....*OOO*...",
        "*O*......*OOO*..",
        "**........*OOO*.",
        "*..........*OOO*",
        "............*OO*",
        ".............***"
    };
    int x, y;

    for (y = 0; y < 16; y++) {
        for (x = 0; x < 16; x++) {
            if (cursor[y][x] == '*') {
                mouse[y * 16 + x] = COL8_000000;
            }
            if (cursor[y][x] == 'O') {
                mouse[y * 16 + x] = COL8_FFFFFF;
            }
            if (cursor[y][x] == '.') {
                mouse[y * 16 + x] = bc;
            }
        }
    }
    return;
}

void putblock8_8(char *vram, int vxsize, int pxsize,
        int pysize, int px0, int py0, char *buf, int bxsize)
{
    int x, y;
    for (y = 0; y < pysize; y++) {
        for (x = 0; x < pxsize; x++) {
            vram[(py0 + y) * vxsize + (px0 + x)] = buf[y * bxsize + x];
        }
    }
    return;
}
