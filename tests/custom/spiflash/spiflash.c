///////////////////////////////////////////////////////////////////////
// spi.c
//
// Written: Jaocb Pease jacob.pease@okstate.edu 8/27/2024
//
// Purpose: C code to test SPI bugs
//
// 
//
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the
// “License”); you may not use this file except in compliance with the
// License, or, at your option, the Apache License version 2.0. You
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an “AS IS” BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
// implied. See the License for the specific language governing
// permissions and limitations under the License.
///////////////////////////////////////////////////////////////////////

#include "spi.h"
#include "uart.h"
#include "norflash.h"
#include <string.h>
#include <stdlib.h>

// Testing SPI peripheral in loopback mode
// TODO: Need to make sure the configuration I'm using uses loopback
//       mode. This can be specified in derivlists.txt
// TODO:

uint8_t spi_txrx(uint8_t byte) {
  spi_sendbyte(byte);
  waittx();
  return spi_readbyte();
}

uint8_t spi_dummy() {
  return spi_txrx(0xff);
}

void spi_set_clock(uint32_t clkin, uint32_t clkout) {
  uint32_t div = (clkin/(2*clkout)) - 1;
  write_reg(SPI_SCKDIV, div);
}

// Initialize Sifive FU540 based SPI Controller
void spi_init(uint32_t clkin) {
  // Enable interrupts
  write_reg(SPI_IE, 0x3);

  // Set TXMARK to 1. If the number of entries is < 1
  // IP's txwm field will go high.
  // Set RXMARK to 0. If the number of entries is > 0
  // IP's rwxm field will go high.
  write_reg(SPI_TXMARK, 1);
  write_reg(SPI_RXMARK, 0);

  // Set Delay 0 to default
  write_reg(SPI_DELAY0,
            SIFIVE_SPI_DELAY0_CSSCK(1) |
			SIFIVE_SPI_DELAY0_SCKCS(1));

  // Set Delay 1 to default
  write_reg(SPI_DELAY1,
            SIFIVE_SPI_DELAY1_INTERCS(1) |
            SIFIVE_SPI_DELAY1_INTERXFR(0));

  // Initialize the SPI controller clock to 
  // div = (20MHz/(2*400kHz)) - 1 = 24 = 0x18 
  write_reg(SPI_SCKDIV, 0x18); 
}


char romeo_and_juliet [] = "Two households, both alike in dignity\
(In fair Verona, where we lay our scene),\
From ancient grudge break to new mutiny,\
Where civil blood makes civil hands unclean.\
From forth the fatal loins of these two foes\
A pair of star-crossed lovers take their life;\
Whose misadventured piteous overthrows\
Doth with their death bury their parents’ strife.\
The fearful passage of their death-marked love\
And the continuance of their parents’ rage,\
Which, but their children’s end, naught could remove,\
Is now the two hours’ traffic of our stage;\
The which, if you with patient ears attend,\
What here shall miss, our toil shall strive to mend.\
Scene 1Enter Sampson and Gregory, with swords and bucklers,\
of the house of Capulet.\
\
SAMPSON  Gregory, on my word we’ll not carry coals.\
GREGORY  No, for then we should be colliers.\
SAMPSON  I mean, an we be in choler, we’ll draw.\
GREGORY  Ay, while you live, draw your neck out of\
collar.\
SAMPSON  I strike quickly, being moved.\
GREGORY  But thou art not quickly moved to strike.\
SAMPSON  A dog of the house of Montague moves me.\
GREGORY  To move is to stir, and to be valiant is to\
stand. Therefore if thou art moved thou runn’st\
away.\
SAMPSON  A dog of that house shall move me to stand. I\
will take the wall of any man or maid of Montague’s.\
GREGORY  That shows thee a weak slave, for the weakest\
goes to the wall.\
SAMPSON  ’Tis true, and therefore women, being the\
weaker vessels, are ever thrust to the wall. Therefore\
I will push Montague’s men from the wall and\
thrust his maids to the wall.\
GREGORY  The quarrel is between our masters and us\
their men.\
SAMPSON  ’Tis all one. I will show myself a tyrant.\
When I have fought with the men, I will be civil\
with the maids; I will cut off their heads.\
GREGORY  The heads of the maids?\
SAMPSON  Ay, the heads of the maids, or their maidenheads.\
Take it in what sense thou wilt.\
GREGORY  They must take it in sense that feel it.\
SAMPSON  Me they shall feel while I am able to stand,\
and ’tis known I am a pretty piece of flesh.\
GREGORY  ’Tis well thou art not fish; if thou hadst, thou\
hadst been poor-john. Draw thy tool. Here comes\
of the house of Montagues.\
\
Enter Abram with another Servingman.\
\
SAMPSON  My naked weapon is out. Quarrel, I will back\
thee.\
GREGORY  How? Turn thy back and run?\
SAMPSON  Fear me not.\
GREGORY  No, marry. I fear thee!\
SAMPSON  Let us take the law of our sides; let them\
begin.\
GREGORY  I will frown as I pass by, and let them take it\
as they list.\
SAMPSON  Nay, as they dare. I will bite my thumb at\
them, which is disgrace to them if they bear it.\
He bites his thumb.\
ABRAM  Do you bite your thumb at us, sir?\
SAMPSON  I do bite my thumb, sir.\
ABRAM  Do you bite your thumb at us, sir?\
SAMPSON, aside to Gregory  Is the law of our side if I\
say “Ay”?\
GREGORY, aside to Sampson  No.\
SAMPSON  No, sir, I do not bite my thumb at you, sir,\
but I bite my thumb, sir.\
GREGORY  Do you quarrel, sir?\
ABRAM  Quarrel, sir? No, sir.\
SAMPSON  But if you do, sir, I am for you. I serve as\
good a man as you.\
ABRAM  No better.\
SAMPSON  Well, sir.\
\
Enter Benvolio.\
\
GREGORY, aside to Sampson  Say “better”; here comes\
one of my master’s kinsmen.\
SAMPSON  Yes, better, sir.\
ABRAM  You lie.\
SAMPSON  Draw if you be men.—Gregory, remember\
thy washing blow.They fight.\
BENVOLIO  Part, fools!Drawing his sword.\
Put up your swords. You know not what you do.\
\
Enter Tybalt, drawing his sword.\
\
TYBALT \
What, art thou drawn among these heartless hinds?\
Turn thee, Benvolio; look upon thy death.\
BENVOLIO \
I do but keep the peace. Put up thy sword,\
Or manage it to part these men with me.\
TYBALT \
What, drawn and talk of peace? I hate the word\
As I hate hell, all Montagues, and thee.\
Have at thee, coward!They fight.\
\
Enter three or four Citizens with clubs or partisans.\
\
CITIZENS \
Clubs, bills, and partisans! Strike! Beat them down!\
Down with the Capulets! Down with the Montagues!\
\
Enter old Capulet in his gown, and his Wife.\
\
CAPULET \
What noise is this? Give me my long sword, ho!\
LADY CAPULET \
A crutch, a crutch! Why call you for a\
sword?\
\
Enter old Montague and his Wife.\
CAPULET \
My sword, I say. Old Montague is come\
And flourishes his blade in spite of me.\
MONTAGUE \
Thou villain Capulet!—Hold me not; let me go.\
LADY MONTAGUE \
Thou shalt not stir one foot to seek a foe.\
\
Enter Prince Escalus with his train.\
\
PRINCE \
Rebellious subjects, enemies to peace,\
Profaners of this neighbor-stainèd steel—\
Will they not hear?—What ho! You men, you beasts,\
That quench the fire of your pernicious rage\
With purple fountains issuing from your veins:\
On pain of torture, from those bloody hands\
Throw your mistempered weapons to the ground,\
And hear the sentence of your movèd prince.\
Three civil brawls bred of an airy word\
By thee, old Capulet, and Montague,\
Have thrice disturbed the quiet of our streets\
And made Verona’s ancient citizens\
Cast by their grave-beseeming ornaments\
To wield old partisans in hands as old,\
Cankered with peace, to part your cankered hate.\
If ever you disturb our streets again,\
Your lives shall pay the forfeit of the peace.\
For this time all the rest depart away.\
You, Capulet, shall go along with me,\
And, Montague, come you this afternoon\
To know our farther pleasure in this case,\
To old Free-town, our common judgment-place.\
Once more, on pain of death, all men depart.\
All but Montague, Lady Montague,\
and Benvolio exit.";


char dst [100000];

void main() {
  spi_init(100000000);

  spi_set_clock(100000000,25000000);
  //spi_set_clock(100000000,50000000);
  
  volatile uint8_t *p = (uint8_t *)(0x8F000000);
  int j;
  uint64_t n = 0;
  uint8_t data;

  write_reg(SPI_CSMODE, SIFIVE_SPI_CSMODE_MODE_HOLD);
  //n = 512/8;

  //int length = strlen(romeo_and_juliet);
  int length = 128;
  // malloc is too much of pain. It's callin sbrk which calls ecall to allocate more memory.
  // solve this later. I'm just going to allocate a giant chunk of memory in the data segment.
  //dst = (char *) malloc(sizeof(char*)*length);

  NorFlashWriteArray(0x0, romeo_and_juliet, length);
  NorFlashReadArray(0x0, dst, length);

  int res = strncmp(romeo_and_juliet, dst, length);

  print_uart("romeo and juliet are same? ");
  if(res) print_uart("no!\n");
  else print_uart("yes!\n");

  write_reg(SPI_CSMODE, SIFIVE_SPI_CSMODE_MODE_AUTO);
}
