// Copyright (c) 2014 Takaaki TSUJIMOTO

void api_putstr0(char *s);
void api_end(void);

void HariMain(void)
{
    api_putstr0("hello, world\n");
    api_end();
}
