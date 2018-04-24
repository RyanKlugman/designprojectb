#include <stdio.h>
#include <sys/types.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv){
	volatile uint32_t* a,*b;
	int fd;
	fd = open("/dev/mem", O_RDWR);
	//Switches
	a = mmap(NULL, 0x1000, PROT_READ|PROT_WRITE,MAP_SHARED, fd, 0x41200000);
	//Leds
	b = mmap(NULL, 0x1000, PROT_READ|PROT_WRITE,MAP_SHARED, fd, 0x41210000);
	printf("0x%x\n",a[0]); //WE ARE READING THE SWITHCES.
	printf("0x%x\n",a[1]); //NO IDEA WHAT THIS IS RN.
	printf("0x%x\n",a[2]);
	printf("0x%x\n",a[3]);
	printf("0x%x\n",b[0]); //WE ARE READING THE SWITHCES.
	printf("0x%x\n",b[1]); //NO IDEA WHAT THIS IS RN. 
	printf("0x%x\n",b[2]);
	printf("0x%x\n",b[3]);
	while(1){
		b[0] = a[0];
	}
	return 0;
}
