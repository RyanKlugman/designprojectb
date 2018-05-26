#include <stdio.h>
#include <sys/types.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#define BASEADDR 0x43C00000
#define TOPADDR 0x43C0FFFF


uint32_t* map(){
	int fd;
	fd = open("/dev/mem", O_RDWR);
	//Switches
	a = mmap(NULL, TOPADDR-BASEADDR, PROT_READ|PROT_WRITE,MAP_SHARED,
		 fd, BASEADDR);
}	

float readFromRegister(int addr, uint32_t * memory){
	int x = (int)memory[addr];
	float d;
	memcpy(&d,&x,sizeof(float));
//	printf("Memory %d is : %f\n",addr,d);
	return d;
}

void writeToRegister(int addr, float data, uint32_t *memory){
	memcpy(&memory[0],&data,sizeof(float));
}

void writeToBRAM(s32 addr, float data,uint32_t * memory) {
	//Xil_Out32(XPAR_AXI_IP_DEMO_0_S00_AXI_BASEADDR+0xC, addr);
	memory[1] = addr;
	printf("Addres to write to is %x\n",(uint32_t) memory[1]);
	//memory[3] = data;
	memcpy(&memory[3],&data,sizeof(float));
	//Xil_Out32(XPAR_AXI_IP_DEMO_0_S00_AXI_BASEADDR+0xC, (1u << 31) | data);
}

float readFromBRAM(s32 addr, uint32_t * memory) {
	//Xil_Out32(XPAR_AXI_IP_DEMO_0_S00_AXI_BASEADDR+0xC, addr);
	memory[1] = addr;	
	printf("Current  Addr: %x\n", (uint32_t)memory[1]);
	int b = (int)memory[3];
	float c;
	memcpy(&c,&b,sizeof(float));
	//float read = (float) memory[3];
	return c;
}