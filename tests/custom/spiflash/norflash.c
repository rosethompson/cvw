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


uint8_t NorFlashRead(uint32_t adr){
  // read address 0x25
  while(!(read_reg(SPI_RXDATA) & 0xC0000000));
  spi_sendbyte((adr >> 24) & 0xFF);
  while(!(read_reg(SPI_RXDATA) & 0xC0000000));
  spi_sendbyte((adr >> 16) & 0xFF);
  while(!(read_reg(SPI_RXDATA) & 0xC0000000));
  spi_sendbyte((adr >> 8) & 0xFF);
  while(!(read_reg(SPI_RXDATA) & 0xC0000000));
  spi_sendbyte(adr & 0xFF);
  // send command 0x1 to read
  while(!(read_reg(SPI_RXDATA) & 0xC0000000));
  spi_sendbyte(0x01);

  // before reading this byte we need to read the junk in the receive fifo
  /* uint32_t res = 0; */
  /* do { */
  /*   res = read_reg(SPI_RXDATA); */
  /*   res = res & 0xC0000000; */
  /*   if(res) { */
  /*     spi_readbyte(); */
  /*   } */
  /* } while (res); */
  //  while ((read_reg(SPI_IP) & 2)) {
  //    volatile int delay;
  //    for (delay = 0; delay < 10; delay++); // Ugh. the SiFive spec is terrible. There is a trace between the fifo empty (or IP) and receiving another byte.
    
  //    spi_readbyte();}
  while(!(read_reg(SPI_RXDATA) & 0xC0000000));
  spi_dummy();
  uint32_t res;
  uint8_t response, Empty, AboutToBeEmpty;
  uint8_t data;

  do {
    res = read_reg(SPI_RXDATA);
    response = (res >> 30) & 0x3;
    Empty = res >> 0x1;
    AboutToBeEmpty = response & 0x1;
    data = res & 0xFF;
  } while(!AboutToBeEmpty);
  
  //while (!(read_reg(SPI_IP) & 2)) {}
  //return spi_readbyte();
  return data;
}
