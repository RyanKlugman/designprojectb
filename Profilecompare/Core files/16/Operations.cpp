#include "Operations.h"
#include "Structs.h"
#include <string.h>
#include <math.h>
#include <sys/mman.h>
#include <fcntl.h>    /* For O_RDWR */
#include <unistd.h>   /* For open(), creat() */
#include <cstdint>

using namespace std;

#define MIN_SUBI	128	//when the subimages reach this size, we will stop our transforms
#define BASEADDR0 0x43C00000
#define TOPADDR0 0x43C0FFFF
#define BASEADDR1 0x43C10000
#define TOPADDR1 0x43C1FFFF
#define BASEADDR2 0x43C20000
#define TOPADDR2 0x43C2FFFF
#define BASEADDR3 0x43C30000
#define TOPADDR3 0x43C3FFFF
#define BASEADDR4 0x43C40000
#define TOPADDR4 0x43C4FFFF
#define BASEADDR5 0x43C50000
#define TOPADDR5 0x43C5FFFF
#define BASEADDR6 0x43C60000
#define TOPADDR6 0x43C6FFFF
#define BASEADDR7 0x43C70000
#define TOPADDR7 0x43C7FFFF

#define BASEADDR8 0x43C80000
#define TOPADDR8 0x43C8FFFF
#define BASEADDR9 0x43C90000
#define TOPADDR9 0x43C9FFFF
#define BASEADDRA 0x43CA0000
#define TOPADDRA 0x43CAFFFF
#define BASEADDRB 0x43CB0000
#define TOPADDRB 0x43CBFFFF
#define BASEADDRC 0x43CC0000
#define TOPADDRC 0x43CCFFFF
#define BASEADDRD 0x43CD0000
#define TOPADDRD 0x43CDFFFF
#define BASEADDRE 0x43CE0000
#define TOPADDRE 0x43CEFFFF
#define BASEADDRF 0x43CF0000
#define TOPADDRF 0x43CFFFFF

#define STOP_SOFT 0
#define START_SOFT 1
#define RESTART_SOFT 2

//Downsamples the x and y resolution of the LH, HL and HH subbands by 2x each. Since most of
//the important info is in the LL sub-band, we can save quite a lot of space with only a small
//drop in quality. After this step we will have less than half the original # of pixels to send.
//The new image size will be stored in img_size and "steps" is the number of sub-band levels to
//downsample (currently you can only do the first level sub-bands, so steps must be 1 or 0).
void Downsample(unsigned char *input, int &img_size, int steps)
{
	if(steps==0) return;  //user can choose no downsampling if they wish
	//w is the length of one side in pixels
	int w = sqrt((float)(img_size/3));
	//there are only so many levels of sub-bands, determined by the image size and MIN_SUBI
	int max_steps = log((float)(w/MIN_SUBI))/log((float)2);
	int row_length = 3 * w; //because each pixel consists of three bytes
	
	//a constant for converting from 2-d array co-ordinate to 1-d array co-ordinates
	//input[i][j] = input[i*array_length + j] (it's easier to visualize in 2-d)
	int array_length = row_length;

	if(steps > max_steps) steps = max_steps;
	int sub_size = img_size / 4;

	//right now, you can only downsample the first set of subbands
	//in the future this feature should be improved
	if(steps > 1) steps = 1;

	//a buffer to hold our changes
	unsigned char *buffer = new unsigned char[(int)(1.75*sub_size)];

	for(int n=steps; n>0; n--)
	{
		//buffer for holding a subimage
		unsigned char *sub = new unsigned char[sub_size];

		//buffer for holding the downsampled subimage data
		unsigned char *dsamp = new unsigned char[(int)(0.75 * sub_size)];

		//grab top-left subimage (we don't want to change it)
		int i, j;
		pixel tl, tr, bl, br, avg;
		for(i=0; i<w/2; i++)
		{
			for(j=0; j<row_length/2; j++)
			{
				sub[i*(row_length/2) +j] = input[i*array_length +j];
			}
		}

		//grab 2x2 groups of pixels and average them
		int a=0;
		for(i=0; i<w; i=i+2)
		{
			for(j=0; j<row_length; j=j+6)
			{
				//ignore data from top-left subimage
				if(i < w/2 && j < row_length/2) continue;
				tl.blue = input[i*row_length +j];
				tl.green = input[i*row_length +j+1];
				tl.red = input[i*row_length +j+2];

				tr.blue = input[i*row_length +j+3];
				tr.green = input[i*row_length +j+4];
				tr.red = input[i*row_length +j+5];

				bl.blue = input[(i+1)*row_length +j];
				bl.green = input[(i+1)*row_length +j+1];
				bl.red = input[(i+1)*row_length +j+2];

				br.blue = input[(i+1)*row_length +j+3];
				br.green = input[(i+1)*row_length +j+4];
				br.red = input[(i+1)*row_length +j+5];

				avg.blue = (tr.blue + tl.blue + br.blue + bl.blue) / 4;
				avg.green = (tr.green + tl.green + br.green + bl.green) / 4;
				avg.red = (tr.red + tl.red + br.red + bl.red) / 4;

				dsamp[a] = avg.blue;
				dsamp[a+1] = avg.green;
				dsamp[a+2] = avg.red;
				a=a+3;				
			}
		}
		//copy top-left subimage to our buffer
		memcpy(buffer, sub, sub_size);

		//copy the averaged data to our buffer
		memcpy(buffer+sub_size, dsamp, (int)(0.75*sub_size));
		/*
		w = w/2;
		row_length = row_length / 2;
		sub_size = sub_size / 4;
		*/
		delete[] sub;
		delete[] dsamp;
	}
	//clear input array
	for(int i=0; i<img_size; i++) input[i]=0;

	//update img_size - one full subimage + 1/4 each of the others, and each
	//subimage is 1/4 the image size
	img_size = 1.75 * (img_size/4);

	//copy our data
	memcpy(input, buffer, img_size);
	delete[] buffer;
}


//Rescales everything to the original size, and puts the updated image size in bytes
//in img_size. The value of steps should be the same as the number of
//downsample steps applied.
void Upsample(unsigned char *input, int &img_size, int steps)
{
	if(steps==0) return;

	img_size = img_size / 1.75 * 4;
	int w = sqrt((float)(img_size/3));
	int row_length = 3 * w; //because each pixel consists of three bytes

	//unpack -- reverse the order we packed in the array
	int sub_size = img_size / 4;
	unsigned char *sub = new unsigned char[sub_size];
	unsigned char *dsamp = new unsigned char[(int)(0.75 * sub_size)];
	memcpy(sub, input, sub_size);
	memcpy(dsamp, input+sub_size, (int)(0.75 * sub_size));
	int i, j;
	int a=0;
		
	//refill the 2x2 blocks with the average
	for(i=0; i<w; i=i+2)
	{
		for(j=0; j<row_length; j=j+6)
		{
			if(i < w/2 && j < row_length/2) continue;  //skip any top-left pixels
			input[i*row_length +j]  = dsamp[a]; //blue
			input[i*row_length +j+1]  = dsamp[a+1]; //green
			input[i*row_length +j+2]  = dsamp[a+2]; //red

			input[i*row_length +j+3] = dsamp[a];
			input[i*row_length +j+4] = dsamp[a+1];
			input[i*row_length +j+5] = dsamp[a+2];

			input[(i+1)*row_length +j]  = dsamp[a];
			input[(i+1)*row_length +j+1]  = dsamp[a+1];
			input[(i+1)*row_length +j+2]  = dsamp[a+2];

			input[(i+1)*row_length +j+3] = dsamp[a];
			input[(i+1)*row_length +j+4] = dsamp[a+1];
			input[(i+1)*row_length +j+5] = dsamp[a+2];
			a=a+3;
		}
	}
	//copy top-left subimage back
	for(i=0; i<w/2; i++)
	{
		for(j=0; j<row_length/2; j++)
		{
			input[i*row_length + j] = sub[i*(row_length/2) +j];
		}
	}
	delete[] sub;
	delete[] dsamp;
}


//First, scales all coefficients so they will fit in an 8-bit char. After the transform
//they could be very large +ve or -ve values, and they need to fit between 0 - 255.
//Then, quanti`zes the pixel values according to the value of amount; ie: reduces the number
//of colours. This leads to better Huffman encoding, so there is a tradeoff between quality
//and compression. Values between 1 and 8 work well for most images.
unsigned char *Quantize(float *input, int img_size, int amount, wlt_header_info &wlt, int acceleration)
{
	
	// 	q[i] = ((unsigned char)input[i]);

	if(amount > 64) amount = 64;
	unsigned char *q = new unsigned char[img_size];
	int i;

	// //first we need to adjust all coefficients to make sure they are between 0 - 255
	// //we will scale them according to the maximum value and then center them around 128
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
	
	if (acceleration == 1){

//		printf("Starting Hardware part\n");

		int fd;
		fd = open("/dev/mem", O_RDWR);
		if(fd == -1){
			printf("No file\n");
			return q;
		}
		uint32_t* registers0;
		registers0 = (uint32_t *) mmap(NULL, TOPADDR0-BASEADDR0, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR0);
			 
		uint32_t* registers1;
		registers1 = (uint32_t *) mmap(NULL, TOPADDR1-BASEADDR1, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR1);
		
		uint32_t* registers2;
		registers2 = (uint32_t *) mmap(NULL, TOPADDR2-BASEADDR2, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR2);
			 
		uint32_t* registers3;
		registers3 = (uint32_t *) mmap(NULL, TOPADDR3-BASEADDR3, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR3);
		
		uint32_t* registers4;
		registers4 = (uint32_t *) mmap(NULL, TOPADDR4-BASEADDR4, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR4);
			 
		uint32_t* registers5;
		registers5 = (uint32_t *) mmap(NULL, TOPADDR5-BASEADDR5, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR5);
		
		uint32_t* registers6;
		registers6 = (uint32_t *) mmap(NULL, TOPADDR6-BASEADDR6, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR6);
			 
		uint32_t* registers7;
		registers7 = (uint32_t *) mmap(NULL, TOPADDR7-BASEADDR7, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR7);
			 
		uint32_t* registers8;
		registers8 = (uint32_t *) mmap(NULL, TOPADDR8-BASEADDR8, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR8);
			 
		uint32_t* registers9;
		registers9 = (uint32_t *) mmap(NULL, TOPADDR9-BASEADDR9, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDR9);
		
		uint32_t* registers10;
		registers10 = (uint32_t *) mmap(NULL, TOPADDRA-BASEADDRA, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDRA);
			 
		uint32_t* registers11;
		registers11 = (uint32_t *) mmap(NULL, TOPADDRB-BASEADDRB, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDRB);
		
		uint32_t* registers12;
		registers12 = (uint32_t *) mmap(NULL, TOPADDRC-BASEADDRC, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDRC);
			 
		uint32_t* registers13;
		registers13 = (uint32_t *) mmap(NULL, TOPADDRD-BASEADDRD, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDRD);
		
		uint32_t* registers14;
		registers14 = (uint32_t *) mmap(NULL, TOPADDRE-BASEADDRE, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDRE);
			 
		uint32_t* registers15;
		registers15 = (uint32_t *) mmap(NULL, TOPADDRF-BASEADDRF, PROT_READ|PROT_WRITE,MAP_SHARED,
			 fd, BASEADDRF);

		int reset = 2;
		int image_height = (int)sqrt(img_size/3);
		int image_width = image_height*3;
		registers0[15] = image_width;
		registers1[15] = image_width;
		registers2[15] = image_width;
		registers3[15] = image_width;
		registers4[15] = image_width;
		registers5[15] = image_width;
		registers6[15] = image_width;
		registers7[15] = image_width;
		registers8[15] = image_width;
		registers9[15] = image_width;
		registers10[15] = image_width;
		registers11[15] = image_width;
		registers12[15] = image_width;
		registers13[15] = image_width;
		registers14[15] = image_width;
		registers15[15] = image_width;

		//Adress 1 hold float Amount
		writeToRegister(1,(float)amount,registers0);
		writeToRegister(1,(float)amount,registers1);
		writeToRegister(1,(float)amount,registers2);
		writeToRegister(1,(float)amount,registers3);
		writeToRegister(1,(float)amount,registers4);
		writeToRegister(1,(float)amount,registers5);
		writeToRegister(1,(float)amount,registers6);
		writeToRegister(1,(float)amount,registers7);
		writeToRegister(1,(float)amount,registers8);
		writeToRegister(1,(float)amount,registers9);
		writeToRegister(1,(float)amount,registers10);
		writeToRegister(1,(float)amount,registers11);
		writeToRegister(1,(float)amount,registers12);
		writeToRegister(1,(float)amount,registers13);
		writeToRegister(1,(float)amount,registers14);
		writeToRegister(1,(float)amount,registers15);
		
		//Regiset 2 holds scale amount
		writeToRegister(2, scale, registers0); //scale
		writeToRegister(2, scale, registers1); //scale
		writeToRegister(2, scale, registers2); //scale
		writeToRegister(2, scale, registers3); //scale
		writeToRegister(2, scale, registers4); //scale
		writeToRegister(2, scale, registers5); //scale
		writeToRegister(2, scale, registers6); //scale
		writeToRegister(2, scale, registers7); //scale
		writeToRegister(2, scale, registers8); //scale
		writeToRegister(2, scale, registers9); //scale
		writeToRegister(2, scale, registers10); //scale
		writeToRegister(2, scale, registers11); //scale
		writeToRegister(2, scale, registers12); //scale
		writeToRegister(2, scale, registers13); //scale
		writeToRegister(2, scale, registers14); //scale
		writeToRegister(2, scale, registers15); //scale

		// printf("AmountFPGA %f\n",readFromRegister(1,registers));
		// printf("ScaleFPGA %f\n",readFromRegister(2,registers));

		registers0[4] = do_scale;
		registers1[4] = do_scale;
		registers2[4] = do_scale;
		registers3[4] = do_scale;
		registers4[4] = do_scale;
		registers5[4] = do_scale;
		registers6[4] = do_scale;
		registers7[4] = do_scale;
		registers8[4] = do_scale;
		registers9[4] = do_scale;
		registers10[4] = do_scale;
		registers11[4] = do_scale;
		registers12[4] = do_scale;
		registers13[4] = do_scale;
		registers14[4] = do_scale;
		registers15[4] = do_scale;
		//printf("Doscale : %d FPGA: %d \n",do_scale,registers[4]);

		for(int r = 0; r < image_height;r+=16) { 
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[r * image_width + i],registers0);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+1) * image_width + i],registers1);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+2) * image_width + i],registers2);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+3) * image_width + i],registers3);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+4) * image_width + i],registers4);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+5) * image_width + i],registers5);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+6) * image_width + i],registers6);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+7) * image_width + i],registers7);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+8) * image_width + i],registers8);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+9) * image_width + i],registers9);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+10) * image_width + i],registers10);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+11) * image_width + i],registers11);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+12) * image_width + i],registers12);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+13) * image_width + i],registers13);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+14) * image_width + i],registers14);
			}
			
			for(int i = 0; i < image_width; i ++){
				writeToBRAM(i, input[(r+15) * image_width + i],registers15);
			}
		// 	for(int i = 0 ; i <15; i++){
			//  	printf("Read from bram :%d value: %f\n",i, readFromBRAM(i,registers));
		//	}
				//starting hardware.
			//printf("Checking Register 0 : %d \n",registers[0]);
			registers0[0] = START_SOFT;
			registers1[0] = START_SOFT;
			registers2[0] = START_SOFT;
			registers3[0] = START_SOFT;
			registers4[0] = START_SOFT;
			registers5[0] = START_SOFT;
			registers6[0] = START_SOFT;
			registers7[0] = START_SOFT;
			
			registers8[0] = START_SOFT;
			registers9[0] = START_SOFT;
			registers10[0] = START_SOFT;
			registers11[0] = START_SOFT;
			registers12[0] = START_SOFT;
			registers13[0] = START_SOFT;
			registers14[0] = START_SOFT;
			registers15[0] = START_SOFT;
			int c = 0;
			// printf("register 5: %d \n",registers[5]);
			while ((registers0[5] == 0) or (registers1[5] == 0) or (registers2[5] == 0) or (registers3[5] == 0) or
					(registers4[5] == 0) or (registers5[5] == 0) or (registers6[5] == 0) or (registers7[5] == 0) or
					(registers8[5] == 0) or (registers9[5] == 0) or (registers10[5] == 0) or (registers11[5] == 0) or
					(registers12[5] == 0) or (registers13[5] == 0) or (registers14[5] == 0) or (registers15[5] == 0)
					){ //polling for done
				c++;	
			}
			registers0[0] = STOP_SOFT;
			registers1[0] = STOP_SOFT;
			registers2[0] = STOP_SOFT;
			registers3[0] = STOP_SOFT;
			registers4[0] = STOP_SOFT;
			registers5[0] = STOP_SOFT;
			registers6[0] = STOP_SOFT;
			registers7[0] = STOP_SOFT;
			
			registers8[0] = STOP_SOFT;
			registers9[0] = STOP_SOFT;
			registers10[0] = STOP_SOFT;
			registers11[0] = STOP_SOFT;
			registers12[0] = STOP_SOFT;
			registers13[0] = STOP_SOFT;
			registers14[0] = STOP_SOFT;
			registers15[0] = STOP_SOFT;
			//printf("register 5: %d \n",registers[5]);
			// printf("Counter:%d\n",c);	
			// printf("Done\n");
			
			for(int i = 0 ; i < image_width; i++){
				q[r * image_width + i] = (unsigned char)readFromIntBRAM(i,registers0);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+1) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers1);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+2) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers2);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+3) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers3);
			}
			
			for(int i = 0 ; i < image_width; i++){
				q[(r+4) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers4);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+5) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers5);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+6) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers6);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+7) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers7);
			}
			
			for(int i = 0 ; i < image_width; i++){
				q[(r+8) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers8);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+9) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers9);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+10) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers10);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+11) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers11);
			}
			
			for(int i = 0 ; i < image_width; i++){
				q[(r+12) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers12);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+13) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers13);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+14) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers14);
			}
			for(int i = 0 ; i < image_width; i++){
				q[(r+15) * image_width + i] = (unsigned char)readFromIntBRAM(i,registers15);
			}
		//	for(int i = 0 ; i <15; i ++){
			//	printf("Read from bram :%d value: %i\n",i, readFromIntBRAM(i,registers));
		//	}
			registers0[0] = RESTART_SOFT;
			registers1[0] = RESTART_SOFT;
			registers2[0] = RESTART_SOFT;
			registers3[0] = RESTART_SOFT;
			registers4[0] = RESTART_SOFT;
			registers5[0] = RESTART_SOFT;
			registers6[0] = RESTART_SOFT;
			registers7[0] = RESTART_SOFT;
			
			registers8[0] = RESTART_SOFT;
			registers9[0] = RESTART_SOFT;
			registers10[0] = RESTART_SOFT;
			registers11[0] = RESTART_SOFT;
			registers12[0] = RESTART_SOFT;
			registers13[0] = RESTART_SOFT;
			registers14[0] = RESTART_SOFT;
			registers15[0] = RESTART_SOFT;
			//a[0] = reset;
		}
		
	} else {
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
		}
	}

	return q;
}


//Rescales all coefficients to their original value after Quantize(...)
void Rescale(float *input, int img_size, wlt_header_info wlt)
{
	for(int i=0; i<img_size; i++)
	{
		input[i] = (input[i] - 128) * wlt.scale;
	}
}


//Convert from RGB to YUV, where img_size is the size of the input in bytes.
void ToYUV(float *input,int img_size)
{
	//Transorm defined as:
	//|Y| = |1/4    1/2     1/4| |R|
	//|U| = |1      -1      0  | |G|
	//|V| = |0      -1      1  | |B|
	float *output = new float[img_size];
	int i;
	pixel rgb;

	for(i=0; i<img_size; i=i+3)
	{
		rgb.blue = input[i];
		rgb.green = input[i+1];
		rgb.red = input[i+2];
		
		output[i] = -1 * rgb.green + rgb.blue;  //V
		output[i+1] = rgb.red - rgb.green;  //U
		output[i+2] = 0.25 * rgb.red + 0.5 * rgb.green + 0.25 * rgb.blue;  //Y
	}
	for(i=0; i<img_size; i++) input[i] = output[i];
	delete[] output;
}


//Convert from YUV to RGB, where img_size is the size of the input in bytes.
void ToRGB(float *input,int img_size)
{
	//Transform defined as:
	//|R| = |1      3/4    -1/4| |Y|
	//|G| = |1     -1/4    -1/4| |U|
	//|B| = |1     -1/4     3/4| |V|
	float *output = new float[img_size];
	int i;
	pixel yuv;

	for(i=0; i<img_size; i=i+3)
	{
		yuv.blue = input[i];		//V
		yuv.green = input[i+1];		//U
		yuv.red = input[i+2];		//Y
		
		output[i] = yuv.red - 0.25 * yuv.green + 0.75 * yuv.blue;   //B	
		output[i+1] = yuv.red - 0.25 * yuv.green - 0.25 * yuv.blue;  //G	
		output[i+2] = yuv.red  + 0.75 * yuv.green - 0.25 * yuv.blue;  //R
	}
	for(i=0; i<img_size; i++) input[i] = output[i];
	delete[] output;
}


//Performs a Daubechies 9/7 wavelet transform on the input image, where img_size is
//the size of the input in bytes.
void Transform97(float *input, int img_size)
{
	//w is the length of one side in pixels
	int w = sqrt((float)(img_size/3));	
	int row_length = 3 * w;
	int i, j, a;
	float *Red = new float[img_size/3];
	float *Green = new float[img_size/3];
	float *Blue = new float[img_size/3];

	//split image data into red, blue, green streams
	for(i=0; i<w; i++)
	{
		a=0;
		for(j=0; j<row_length; j=j+3)
		{
			Blue[i*w + a] = input[i*row_length + j];
			Green[i*w + a] = input[i*row_length + j+1];
			Red[i*w + a] = input[i*row_length + j+2];
			a++;
		}
	}
	//transform each separately
	TransformStream(Red, img_size/3);
	TransformStream(Green, img_size/3);
	TransformStream(Blue, img_size/3);

	//recombine streams
	for(i=0; i<w; i++)
	{
		a=0;
		for(j=0; j<row_length; j=j+3)
		{
			input[i*row_length + j] = Blue[i*w + a];
			input[i*row_length + j+1] = Green[i*w + a];
			input[i*row_length + j+2] = Red[i*w + a];
			a++;
		}
	}
	delete[] Red;
	delete[] Green;
	delete[] Blue;
}

//Transforms a single channel (red, blue, green) of the image
void TransformStream(float *input, int img_size)
{
	int w = sqrt((float)(img_size));
	//set a limit on how small the smallest subimage can be
	//we call this function recursively until it reaches this limit
	if(w == MIN_SUBI) return;
	int i, j;
	//temp array for the transform
	float *vector = new float[w];

	//apply transform to rows
	for(i=0; i<w; i++)
	{
		//get row
		for(j=0; j<w; j++)
		{
			vector[j] = input[i*w + j];
		}
		//apply transform
		Step97(vector, w);
		//copy back
		for(j=0; j<w; j++)
		{
			input[i*w + j] = vector[j];
		}
	}
	//now apply transform to the columns of our new array
	for(j=0; j<w; j++)
	{
		//get column
		for(i=0; i<w; i++)
		{
			vector[i] = input[i*w + j];
		}
		//apply transform
		Step97(vector, w);
		//copy back
		for(i=0; i<w; i++)
		{
			input[i*w + j] = vector[i];
		}
	}
	//copy top-left subimage into a new array and repeat
	float *subimage = new float[img_size/4];
	for(i=0; i<w/2; i++)
	{
		for(j=0; j<w/2; j++)
		{
			subimage[i*(w/2) + j] = input[i*w + j];
		}
	}
	TransformStream(subimage, img_size/4);

	//copy new subimage back to top left corner
	for(i=0; i<w/2; i++)
	{
		for(j=0; j<w/2; j++)
		{
			input[i*w + j] = subimage[i*(w/2) + j];
		}
	}
	delete[] vector;
}

//Applies the filters to the input (as a 1-d array). Used on one row or column
//of image data at a time. Taken from a sample algorithm at http://www.ebi.ac.uk/~gpau/misc/dwt97.c
void Step97(float* input, int img_size)
{
	float a;
	int i;

	// Predict 1
	a=-1.586134342;
	for (i=1;i<img_size-2;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	} 
	input[img_size-1]+=2*a*input[img_size-2];

	// Update 1
	a=-0.05298011854;
	for (i=2;i<img_size;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	}
	input[0]+=2*a*input[1];

	// Predict 2
	a=0.8829110762;
	for (i=1;i<img_size-2;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	}
	input[img_size-1]+=2*a*input[img_size-2];

	// Update 2
	a=0.4435068522;
	for (i=2;i<img_size;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	}
	input[0]+=2*a*input[1];

	// Scale
	a=1/1.149604398;
	for (i=0;i<img_size;i++)
	{
		if (i%2) input[i]*=a;
		else input[i]/=a;
	}

	// Pack
	float *temp = new float[img_size];
	for (i=0;i<img_size;i++)
	{
		if (i%2==0) temp[i/2]=input[i];
		else temp[img_size/2+i/2]=input[i];
	}
	for (i=0;i<img_size;i++) input[i]=temp[i];
	delete[] temp;
}

//Performs a Daubechies 9/7 Inverse transfom
void Inverse97(float *input, int img_size, int steps)
{
	int w = sqrt((float)(img_size/3));
	int row_length = 3 * w;
	int i, j, a;
	float *Red = new float[img_size/3];
	float *Green = new float[img_size/3];
	float *Blue = new float[img_size/3];

	//split image data into red, blue, green streams
	for(i=0; i<w; i++)
	{
		a=0;
		for(j=0; j<row_length; j=j+3)
		{
			Blue[i*w + a] = input[i*row_length + j];
			Green[i*w + a] = input[i*row_length + j+1];
			Red[i*w + a] = input[i*row_length + j+2];
			a++;
		}
	}
	//transform each separately
	InverseStream(Red, img_size/3, steps);
	InverseStream(Green, img_size/3, steps);
	InverseStream(Blue, img_size/3, steps);

	//recombine streams
	for(i=0; i<w; i++)
	{
		a=0;
		for(j=0; j<row_length; j=j+3)
		{
			input[i*row_length + j] = Blue[i*w + a];
			input[i*row_length + j+1] = Green[i*w + a];
			input[i*row_length + j+2] = Red[i*w + a];
			a++;
		}
	}
	delete[] Red;
	delete[] Green;
	delete[] Blue;
}

//Performs an Inverse on a single stream (red, blue, or green)
//"steps" is the number of downsample steps performed during compression
void InverseStream(float *input, int img_size, int steps)
{
	//w_orig is the length of one side of the original image in pixels
	//w_sub should initially be float the length of one side of the smallest subimage
	int w_sub = 2 * MIN_SUBI;// * pow((float)2, steps);
	int w_orig = sqrt((float)(img_size));
	int i, j;
	//number of inverses needed
	int n = log((float)(w_orig/w_sub))/log((float)2);
	int row_length = w_orig;

	do
	{
		//temp array for the inverse
		float *vector = new float[w_sub];
		float *subimage = new float[w_sub*w_sub];

		//get the top-left subimages to transform
		for(i=0; i<w_sub; i++)
		{
			for(j=0; j<w_sub; j++)
			{
				subimage[i*w_sub + j] = input[i*row_length + j];
			}
		}

		//first apply inverse to the columns of our new array
		for(j=0; j<w_sub; j++)
		{
			//get column
			for(i=0; i<w_sub; i++)
			{
				vector[i] = subimage[i*w_sub + j];
			}
			//apply inverse
			InvStep97(vector, w_sub);
			//copy back
			for(i=0; i<w_sub; i++)
			{
				subimage[i*w_sub + j] = vector[i];
			}
		}
		//now apply inverse to rows
		for(i=0; i<w_sub; i++)
		{
			//get row
			for(j=0; j<w_sub; j++)
			{
				vector[j] = subimage[i*w_sub + j];
			}
			//apply inverse
			InvStep97(vector, w_sub);
			//copy back
			for(j=0; j<w_sub; j++)
			{
				subimage[i*w_sub + j] = vector[j];
			}
		}
		//copy the inversed subimage back to the original image and repeat
		for(i=0; i<w_sub; i++)
		{
			for(j=0; j<w_sub; j++)
			{
				input[i*row_length + j] = subimage[i*w_sub + j];
			}
		}
		delete[] subimage;
		delete[] vector;
		n--;
		w_sub = w_sub * 2;
	}while(n != -1);
}

//Performs a filter inverse on a one-dimensional array. Use on a row or column of
//image data. Taken from a sample algorithm at http://www.ebi.ac.uk/~gpau/misc/dwt97.c
void InvStep97(float* input, int img_size)
{
	float a;
	int i;

	// Unpack
	float *temp = new float[img_size];
	for (i=0;i<img_size/2;i++)
	{
		temp[i*2]=input[i];
		temp[i*2+1]=input[i+img_size/2];
	}
	for (i=0;i<img_size;i++) input[i]=temp[i];

	// Undo scale
	a=1.149604398;
	for (i=0;i<img_size;i++)
	{
		if (i%2) input[i]*=a;
		else input[i]/=a;
	}

	// Undo update 2
	a=-0.4435068522;
	for (i=2;i<img_size;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	}
	input[0]+=2*a*input[1];

	// Undo predict 2
	a=-0.8829110762;
	for (i=1;i<img_size-2;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	}
	input[img_size-1]+=2*a*input[img_size-2];

	// Undo update 1
	a=0.05298011854;
	for (i=2;i<img_size;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	}
	input[0]+=2*a*input[1];

	// Undo predict 1
	a=1.586134342;
	for (i=1;i<img_size-2;i+=2)
	{
		input[i]+=a*(input[i-1]+input[i+1]);
	} 
	input[img_size-1]+=2*a*input[img_size-2];
}

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
int readFromIntBRAM(int32_t addr, uint32_t * memory){
	memory[8] = addr;	
	return memory[6];
}
