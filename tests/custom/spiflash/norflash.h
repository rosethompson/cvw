#ifndef __NORFLASH_H
#define __NORFLASH_H

void NorFlashWrite(uint32_t adr, uint8_t data);
uint8_t NorFlashRead(uint32_t adr);
void NorFlashWriteArray(uint32_t adr, char * src, int length);
void NorFlashReadArray(uint32_t adr, char *dst, int length);

#endif
