#include "Structs.h"
#include "Image.h"
#include "float.cpp"
#include <iostream>


int main()
{
	//cout << "Hello World";
	
	float *img = NULL;
	unsigned char *header = NULL;
	int sz_header = 0;
	int sz_img = 0;
	char *fname = (char *)"1mp.bmp";

	if (!LoadBMP(fname, header, sz_header, img, sz_img)) {
		printf("Error opening bmp file \n\n");
		return 0;
	}

	int bram_size = 10;
	int times = sz_img / bram_size;
	float *partition = new float[bram_size];
	int reset = 1;
	int soft_start = 2;
	float amount;
	int int_amount = (int) amount;
	float scale;
	int doscale;
	int done;

	for (int i = 0; i < times; i++) {
		int k = i * bram_size;
		int end = (i + 1)*bram_size;

		for (k; k < end; k++) {
			partition[k - (i*bram_size)] = img[k];
		}
		
		// write to Bram
		uint32_t a = map();
		for (int l = 0 ; l < bram_size ; l++){
			writeToBRAM(l, partition[l],a);
		}
		
		writeToRegister(1, amount, a); //amount
		a[2] = int_amount;				//int_amount
		writeToRegister(3, scale, a); //scale
		a[4] = doscale; //doscale
		a[0] = start; // assert start
		// quantise start signal
		
	/*	for (int l = 0 ; l < bram_size ; l++){
			cout << "read at address " + to_string(l) + " : " + to_string(readFromBRAM(l,a)) + "\n";
		}*/
		
			
		// quantize done signal + read from bram
		while ((a[5] = 0)){ //polling for done
			
		}
		
		a[0] = reset;
		
		for (int l = 0 ; l < bram_size ; l++){
			partition[l] = readFromBRAM(l,a);
		}
		
		int k = i * bram_size;
		int end = (i + 1)*bram_size;
		for (k; k < end; k++) {
			img[k] = partition[k - (i*bram_size)];
		}


	}
    return 0;
}