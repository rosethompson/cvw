#include "spi.h"
#include <stdint.h>

inline void write_reg(uintptr_t addr, uint32_t value) {
  volatile uint32_t * loc = (volatile uint32_t *) addr;
  *loc = value;
}

// Read a register
inline uint32_t read_reg(uintptr_t addr) {
  return *(volatile uint32_t *) addr;
}

// Queues a single byte in the transfer fifo
inline void spi_sendbyte(uint8_t byte) {
  // Write byte to transfer fifo
  write_reg(SPI_TXDATA, byte);
}

inline void waittx() {
  while(!(read_reg(SPI_IP) & 1)) {}
}

inline void waitrx() {
  while(read_reg(SPI_IP) & 2) {}
}

inline uint8_t spi_readbyte() {
  return read_reg(SPI_RXDATA);
}
