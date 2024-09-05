all: rvvidaemon

rvvidaemon: rvvidaemon.o
	gcc $^ $(RISCV)/ImperasDV-OpenHW/Imperas/lib/Linux64/ImperasLib/imperas.com/verification/riscv/1.0/model.so  -o rvvidaemon

%.o:%.c
	gcc -I$(RISCV)/ImperasDV-OpenHW/Imperas/ImpProprietary/include/host -I$(RISCV)/ImperasDV-OpenHW/Imperas/ImpPublic/include/host/rvvi/ -c $^ -o $@

clean:
	rm *.o rvvidaemon
