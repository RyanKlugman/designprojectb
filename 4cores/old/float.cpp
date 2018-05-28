#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <cstdint>
#include "Float.h"


float readFromRegister(int addr, uint32_t * memory){
	int x = (int)memory[addr];
	float d;
	memcpy(&d,&x,sizeof(float));
//	printf("Memory %d is : %f\n",addr,d);
	return d;
}

void writeToRegister(int addr, float data, uint32_t *memory){
	memcpy(&memory[addr],&data,sizeof(float));
}

void writeToBRAM(int32_t addr, float data,uint32_t * memory) {
	memory[8] = addr;
	memcpy(&memory[7],&data,sizeof(float));
}

float readFromBRAM(int32_t addr, uint32_t * memory) {
	memory[8] = addr;	
	int b = (int)memory[6];
	float c;
	memcpy(&c,&b,sizeof(float));
	return c;
}