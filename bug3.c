// Copyright (c) 2014 Takaaki TSUJIMOTO

void api_putchar(int c);
void api_end(void);

void HariMain(void)
{
    for (;;) {
        api_putchar('a');
    }
}
