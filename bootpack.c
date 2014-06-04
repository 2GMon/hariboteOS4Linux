// Copyright (c) 2014 Takaaki TSUJIMOTO
#include "bootpack.h"

void HariMain(void)
{
    struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
    char s[40], mcursor[256];
    int mx, my;

    init_gdtidt();
    init_palette(); /* パレットを設定 */
    init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
    mx = (binfo->scrnx - 16) / 2; /* 画面中央になるように座標計算 */
    my = (binfo->scrny - 28 - 16) / 2;
    init_mouse_cursor8(mcursor, COL8_008484);
    putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);
    lsprintf(s, "(%d, %d)", mx, my);
    putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

    for (;;) {
        io_hlt();
    }
}
