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