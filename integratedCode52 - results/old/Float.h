#ifndef _Operations_h
#define _Operations_h

#include "Structs.h"


void writeToBRAM(int32_t addr, float data,uint32_t * memory);
float readFromBRAM(int32_t addr, uint32_t * memory);
float readFromRegister(int addr, uint32_t * memory);
void writeToRegister(int addr, float data, uint32_t *memory);

#endif