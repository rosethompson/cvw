#include "spi.h"
#include "norflash.h"

void NorFlashWrite(uint32_t adr, uint8_t data){
  while(read_reg(SPI_TXDATA) & 0xC0000000);
  spi_sendbyte((adr >> 24) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0xC0000000);
  spi_sendbyte((adr >> 16) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0xC0000000);
  spi_sendbyte((adr >> 8) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0xC0000000);
  spi_sendbyte(adr & 0xFF);
  // send command 0x2 to write
  while(read_reg(SPI_TXDATA) & 0xC0000000);
  spi_sendbyte(0x02);
  while(read_reg(SPI_TXDATA) & 0xC0000000);
  spi_sendbyte(data);
}

void NorFlashWriteArray(uint32_t adr, char * src, int length){
  int index;
  for(index = 0; index < length; index++){
    NorFlashWrite(index, src[index]);
  }
}

void NorFlashReadArray(uint32_t adr, char *dst, int length){
  int index;
  for(index = 0; index < length; index++){
    dst[index] = NorFlashRead(index);
  }
}

uint8_t NorFlashRead(uint32_t adr){
  // read address 0x25
  while((read_reg(SPI_RXDATA) & 0xC0000000) != 0xC0000000);
  spi_sendbyte((adr >> 24) & 0xFF);
  while((read_reg(SPI_RXDATA) & 0xC0000000) != 0xC0000000);
  spi_sendbyte((adr >> 16) & 0xFF);
  while((read_reg(SPI_RXDATA) & 0xC0000000) != 0xC0000000);
  spi_sendbyte((adr >> 8) & 0xFF);
  while((read_reg(SPI_RXDATA) & 0xC0000000) != 0xC0000000);
  spi_sendbyte(adr & 0xFF);
  // send command 0x1 to read
  while((read_reg(SPI_RXDATA) & 0xC0000000) != 0xC0000000);
  spi_sendbyte(0x01);
    
  //    spi_readbyte();}
  while((read_reg(SPI_RXDATA) & 0xC0000000) != 0xC0000000);
  spi_dummy();
  uint32_t res;

  // this whole thing is dumb.
  // lets wait until the ip bit is set to know we have data
  waitrx();
  res = read_reg(SPI_RXDATA);
  return res & 0xFF;
}
