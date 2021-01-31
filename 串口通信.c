#include <reg52.h>

#define true 1
#define false 0
#define uint unsigned int
#define uchar unsigned char
	
void Init_UART();

int main()
{
	Init_UART();
	
	while (true)
	{

	}
}

void Init_UART()
{
	EA = 1;
	SCON = 0x50;
	PCON |= 0x80;
	//PCON &= 0x7F;
	TMOD &= 0x0F;
	TMOD |= 0x20;
	TH1 = 256-12000000L/12/16/4800;
	TL1 = TH1;
	// 关闭定时器1中断
	ET1 = 0;
	// 打开串口中断
	ES = 1;
	TR1 = 1;
}

void UART_INTERRUPT() interrupt 4
{
	if (RI)
	{
		RI = 0;
		SBUF = SBUF;
	}
	if (TI)
	{
		TI = 0;
	}
}

