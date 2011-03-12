#include<8051.h>

void delay()
{
    int i=0;
    for (i=0;i<100;i++)
    {
        for (i=0;i<255;i++);
    }
}

void main()
{
    sbit LED = P1^0;
    while (1)
    {
        delay();
        P1_0 = ~P1_0;
    }
}

