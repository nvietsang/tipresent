/*
    This file is part of the ChipWhisperer Example Targets
    Copyright (C) 2012-2020 NewAE Technology Inc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "hal.h"
#include "simpleserial.h"

#include <string.h>
#include <stdio.h>
#include <time.h>
#include <stdint.h>
#include <stdlib.h>

#define ROUND(n)       \
    ARK(shares);       \
    SLAYER(shares);    \
    PLAYER(shares);    \
    KS(shares, n);

extern void add_roundkey(uint32_t* s);
extern void sboxpair(uint32_t* s);
extern void playerbyte(uint32_t* s);
extern void key_schedule(uint32_t* s);

void ARK(uint32_t* shares){
    add_roundkey(shares);
}

void SLAYER(uint32_t* shares){
    shares[15] = 0;
    sboxpair(shares);
    shares[15] = 1;
    sboxpair(shares);
    shares[15] = 2;
    sboxpair(shares);
    shares[15] = 3;
    sboxpair(shares);
    shares[15] = 4;
    sboxpair(shares);
    shares[15] = 5;
    sboxpair(shares);
    shares[15] = 6;
    sboxpair(shares);
    shares[15] = 7;
    sboxpair(shares);
}

void PLAYER(uint32_t* shares){
    uint32_t newlo;
    uint32_t newhi;
    shares[15] = 0x0100; playerbyte(shares); newlo  = (shares[15] >> 24);
    shares[15] = 0x0104; playerbyte(shares); newlo ^= (shares[15] >> 24) << 8;
    shares[15] = 0x0200; playerbyte(shares); newlo ^= (shares[15] >> 24) <<16;
    shares[15] = 0x0204; playerbyte(shares); newlo ^= (shares[15] >> 24) <<24;
    shares[15] = 0x0400; playerbyte(shares); newhi  = (shares[15] >> 24);
    shares[15] = 0x0404; playerbyte(shares); newhi ^= (shares[15] >> 24) << 8;
    shares[15] = 0x0800; playerbyte(shares); newhi ^= (shares[15] >> 24) <<16;
    shares[15] = 0x0804; playerbyte(shares); newhi ^= (shares[15] >> 24) <<24;
    shares[0] = newlo;
    shares[1] = newhi;
    shares[15] = 0x0108; playerbyte(shares); newlo  = (shares[15] >> 24);
    shares[15] = 0x010c; playerbyte(shares); newlo ^= (shares[15] >> 24) << 8;
    shares[15] = 0x0208; playerbyte(shares); newlo ^= (shares[15] >> 24) <<16;
    shares[15] = 0x020c; playerbyte(shares); newlo ^= (shares[15] >> 24) <<24;
    shares[15] = 0x0408; playerbyte(shares); newhi  = (shares[15] >> 24);
    shares[15] = 0x040c; playerbyte(shares); newhi ^= (shares[15] >> 24) << 8;
    shares[15] = 0x0808; playerbyte(shares); newhi ^= (shares[15] >> 24) <<16;
    shares[15] = 0x080c; playerbyte(shares); newhi ^= (shares[15] >> 24) <<24;
    shares[2] = newlo;
    shares[3] = newhi;
    shares[15] = 0x0110; playerbyte(shares); newlo  = (shares[15] >> 24);
    shares[15] = 0x0114; playerbyte(shares); newlo ^= (shares[15] >> 24) << 8;
    shares[15] = 0x0210; playerbyte(shares); newlo ^= (shares[15] >> 24) <<16;
    shares[15] = 0x0214; playerbyte(shares); newlo ^= (shares[15] >> 24) <<24;
    shares[15] = 0x0410; playerbyte(shares); newhi  = (shares[15] >> 24);
    shares[15] = 0x0414; playerbyte(shares); newhi ^= (shares[15] >> 24) << 8;
    shares[15] = 0x0810; playerbyte(shares); newhi ^= (shares[15] >> 24) <<16;
    shares[15] = 0x0814; playerbyte(shares); newhi ^= (shares[15] >> 24) <<24;
    shares[4] = newlo;
    shares[5] = newhi;
}

void KS(uint32_t* shares, uint32_t rc){
    shares[15] = rc;
    key_schedule(shares);
}

uint8_t ti_present(uint8_t cmd, uint8_t scmd, uint8_t len, uint8_t* indata){
    uint32_t shares[16];
    trigger_high();

    ROUND(1)
    ROUND(2)
    ROUND(3)
    ROUND(4)
    ROUND(5)
    ROUND(6)
    ROUND(7)
    ROUND(8)
    ROUND(9)
    ROUND(10)
    ROUND(11)
    ROUND(12)
    ROUND(13)
    ROUND(14)
    ROUND(15)
    ROUND(16)
    ROUND(17)
    ROUND(18)
    ROUND(19)
    ROUND(20)
    ROUND(21)
    ROUND(22)
    ROUND(23)
    ROUND(24)
    ROUND(25)
    ROUND(26)
    ROUND(27)
    ROUND(28)
    ROUND(29)
    ROUND(30)
    ROUND(31)

    trigger_low();

    uint8_t* outdata = (uint8_t*) shares;
    simpleserial_put('r', 64, outdata);
    return 0;
}

int main(void)
{
    platform_init();
    init_uart();
    trigger_setup();

    /* Device reset detected */
    putch('r');
    putch('R');
    putch('E');
    putch('S');
    putch('E');
    putch('T');
    putch(' ');
    putch(' ');
    putch(' ');
    putch('\n');

    simpleserial_init();
    simpleserial_addcmd('a', 60, ti_present);

    while(1)
        simpleserial_get();
}
