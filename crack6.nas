; Copyright (c) 2014 Takaaki TSUJIMOTO

[BITS 32]
    MOV EDX,123456789
    INT 0x40
    MOV EDX,4
    INT 0x40
