//Functions for loading/saving bmp and compressed files
////////////////////////////////////////////////////////////

#ifndef _Image_h
#define _Image_h

#include "Structs.h"

//loads a bmp file into memory for compression
int LoadBMP(char *fname, unsigned char *&header_addr, int &header_size, float *&img_addr, int &img_size);

//saves a bmp file after decompression
int SaveBMP(char *fname, unsigned char *header_data, int header_size, float *img_data, int img_size);

//saves a compressed file (extension is .wlt)
int SaveWLT(char *fname, wlt_header_info wlt, unsigned char *bmp_header_data,
	int bmp_header_size, unsigned char *img_data, int img_size);

//loads a compressed file
int LoadWLT(char *fname, wlt_header_info &wlt, unsigned char *&bmp_header_addr, int &bmp_header_size,
	unsigned char *&img_addr, int &img_size);

#endif#pragma once
