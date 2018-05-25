#include <stdlib.h>
#include <stdio.h>

void Quantize(float input, float amount, int do_scale, float scale, unsigned char *q)
{
    //scale to between 0 - 255
    if (do_scale == 1) input = (input / scale) + 128;
    //now, quantize the pixel values
    input = input / amount;
    input = (int)(input + 0.5); //round up or down
    input = input * amount; //scale back up
    if (input > 255) input = 255;
    if (input < 0) input = 0;
    *q = ((unsigned char)input);
}
int main() {
    float amount = 4;
    float input[] = {24.2, 53.7, 101.2, 4.444, 90.7};
    float scale = 5;
    int do_scale = 1;
    unsigned char q = 0;
    
    printf("amount: %f, %x\n", amount, *(int*)&amount);
    printf("scale: %f, %x\n", scale, *(int*)&scale);
    printf("do_scale: %d, %x\n", do_scale, do_scale);
    for (int i = 0; i < 5; i++) {
        Quantize(input[i], amount, do_scale, scale, &q);
        printf("input%d: %f, %x\n", i, input[i], *(int*)(input + i));
        printf("q%d: %d, %x\n", i, q, q);
    }
    return 0;
}