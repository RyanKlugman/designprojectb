#include <fstream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

using namespace std;

int main(int argc, char *argv[])
{
	char *fname1 = argv[1];
	fstream file1;
	//open with position pointer at end of file
	file1.open(fname1, ios::in | ios::binary);
	if(!file1.is_open()) {
		printf("Failed to open file 1\n");
		return 0;
	}

	//get the filesize
	file1.seekg(0, ios::end);
	long size1 = file1.tellg(); 
	file1.seekg(ios::beg); //back to beginning of file

	unsigned char *mem1 = new unsigned char[size1];
	file1.read((char *)mem1, size1);
	file1.close();

	char *fname2 = argv[2];
	fstream file2;
	//open with position pointer at end of file
	file2.open(fname2, ios::in | ios::binary);
	if(!file2.is_open()) {
		printf("Failed to open file 2\n");
		return 0;	
	}

	//get the filesize
	file2.seekg(0, ios::end);
	long size2 = file2.tellg(); 
	file2.seekg(ios::beg); //back to beginning of file

	unsigned char *mem2 = new unsigned char[size2];
	file2.read((char *)mem2, size2);
	file2.close();

	printf("Image 1 size: %ld\n", size1);
	printf("Image 2 size: %ld\n", size2);
	
	if (size1 != size2) {
		printf("Images are not the same size!\n");
		return 0;
	}
	
	if (memcmp (mem1, mem2, size1) != 0) {
		printf("Images are not identical!\n");
		return 0;
	}
	
	printf("All good. The images are identical.\n");

	return 0;
}