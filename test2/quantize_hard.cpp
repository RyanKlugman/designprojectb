#include "Operations.h"
#include "Structs.h"
#include "float.cpp"
#include <string.h>
#include <math.h>

unsigned char *Quantize_hard(float *input, int img_size, int amount, wlt_header_info &wlt)
{
	//if(amount > 64) amount = 64;
	unsigned char *q = new unsigned char[img_size];

	if(amount > 64) amount = 64;
	float max=0;
	int do_scale = 0;
	for(int i=0; i<img_size; i++)
	{
		int abs;
		if(input[i] < 0) abs = input[i] * (-1);
		else abs = input[i];
		if(abs > max) max = abs;
	}
	if(max > 255) do_scale = 1;
	float scale = max / 128;
	wlt.scale = scale; //we will need this value on decompression


	int bram_size = 10;
	int times = img_size / bram_size;
	float *partition = new float[bram_size];
	int reset = 1;
	int soft_start = 2;
	//float amount;
	int int_amount = (int) amount;
	//float scale;
	//int doscale;
	//int done;

	for (int i = 0; i < times; i++) {
		int k = i * bram_size;
		int end = (i + 1)*bram_size;

		for (k; k < end; k++) {
			partition[k - (i*bram_size)] = input[k];
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
		a[0] = soft_start; // assert start
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
			input[k] = partition[k - (i*bram_size)];
		}


	}
	/*int i;

	//first we need to adjust all coefficients to make sure they are between 0 - 255
	//we will scale them according to the maximum value and then center them around 128
	float max=0;
	int do_scale = 0;
	for(i=0; i<img_size; i++)
	{
		int abs;
		if(input[i] < 0) abs = input[i] * (-1);
		else abs = input[i];
		if(abs > max) max = abs;
	}
	if(max > 255) do_scale = 1;
	float scale = max / 128;
	wlt.scale = scale; //we will need this value on decompression

	for(i=0; i<img_size; i++)
	{
		//scale to between 0 - 255
		if(do_scale == 1) input[i] = (input[i] / scale) + 128;
		//now, quantize the pixel values
		input[i] = input[i] / amount;
		input[i] = (int)(input[i]+0.5); //round up or down
		input[i] = input[i] * amount; //scale back up
		if(input[i] > 255) input[i]=255;
		if(input[i] < 0) input[i]=0;
		q[i] = ((unsigned char)input[i]);
	}*/
	return q;
}