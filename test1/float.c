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

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef char char8;
typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;
typedef uint64_t u64;
typedef int sint32;

void writeToBRAM(s32 addr, float data,uint32_t * memory);
float readFromBRAM(s32 addr, uint32_t * memory);
float readFromRegister(int addr, uint32_t * memory);
void writeToRegister(int addr, float data, uint32_t *memory);

int main(int argc, char **argv){
	uint32_t* a;
	int fd;
	fd = open("/dev/mem", O_RDWR);
	//Switches
	a = mmap(NULL, TOPADDR-BASEADDR, PROT_READ|PROT_WRITE,MAP_SHARED,
		 fd, BASEADDR);
	//Leds
	printf("sizeof float %d\n",sizeof(uint32_t));
	printf("sizeof int %d\n",sizeof(int));
	printf("Curr 0:%p\n",&a[0]);
	printf("Curr 1:%p\n",&a[1]);
	printf("Curr 2:%p\n",&a[2]);
	printf("Curr 3:%p\n",&a[3]);
	writeToBRAM(0x0, 125.65f,a);
	printf("first read at address 0 is %f\r\n", readFromBRAM(0x0,a));
	printf("\n");	
	writeToBRAM(0x1, 111.11f,a);
	//int b = (int)readFromBRAM(0x1,a);
	//float c;
	//memcpy(&c,&b,sizeof(float));
//	printf("Result from memcpy: %f \n",c);
	printf("first read at address 1 is %f\r\n", readFromBRAM(0x1,a));
	printf("\n");
	writeToBRAM(0x2, 2.5f,a);
	printf("first read at address 2 is %f\r\n", readFromBRAM(0x2,a));	
	printf("\n\n");

   	printf("first read at address 0 is %f\r\n", readFromBRAM(0x0,a));
  	printf("first read at address 1 is %f\r\n", readFromBRAM(0x1,a));
   	printf("first read at address 2 is %f\r\n", readFromBRAM(0x2,a));

	///a[1] = 15;
	writeToRegister(0,1162.2241f,a);
	printf("Register 0 is %f\r\n", readFromRegister(0,a));
   	printf("Register 3 is %f\r\n", readFromRegister(3,a));
   	a[1] = 15;
	usleep(1);
	//while(1){
   		printf("Register 0 is %f\r\n", readFromRegister(2,a));
//	}

	return 0;
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
