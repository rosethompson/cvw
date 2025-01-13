all: rvvidaemon queue_tb rvvidaemon-multithread  csr-test

rvvidaemon-multithread: queue.o rvvidaemon-multithread.o
	gcc $^ -o $@ $(RISCV)/ImperasDV-OpenHW/Imperas/lib/Linux64/ImperasLib/imperas.com/verification/riscv/1.0/model.so

queue_tb: queue.o queue_tb.o
	gcc $^ -o $@

csr-test: csr-test.o
	gcc $^ -o $@

rvvidaemon: rvvidaemon.o
	gcc $^ $(RISCV)/ImperasDV-OpenHW/Imperas/lib/Linux64/ImperasLib/imperas.com/verification/riscv/1.0/model.so  -o rvvidaemon

%.o:%.c
	gcc -I$(RISCV)/ImperasDV-OpenHW/Imperas/ImpProprietary/include/host -I$(RISCV)/ImperasDV-OpenHW/Imperas/ImpPublic/include/host/rvvi/ -I$(RISCV)/ImperasDV-OpenHW/Imperas/ImpPublic/include/host -c $^ -o $@

clean:
	rm *.o rvvidaemon
