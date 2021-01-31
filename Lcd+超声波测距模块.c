
#include "Lcd1602.h"
#include <intrins.h>

// 12000000/12 = 1s
#define Time0TH0 60  // (65536-50000)/256
#define Time0TL0 176  // (65536-50000)%256

sbit Trig = P2^1;
sbit Echo = P2^0;
bit  flag = 0;

void Init();
void LcdShowDistance(uint num);
uint GetDistance();

void main()
{
	Init();
	
	while (1)
	{
		
	}
}

void Init()
{
	// 关闭数码管
	P1 &= 0xF0;
	// 初始化Lcd1602
	LcdInit();
	
	// 总中断打开
	EA = 1;
	// 打开定时器0和定时器1
	TMOD &= 0x00;
	TMOD |= 0x11;
	// 50ms
	TH0 = Time0TH0;
	TL0 = Time0TL0;
	// 定时器1
	TH1 = 0;
	TL1 = 0;
	// 允许定时器0中断
	ET0 = 1;
	// 定时器0开始计时
	TR0 = 1;
	
	TR1 = 0;
	ET1 = 1;
}

void Time0Inter() interrupt 1
{
	static uint num=0;
	// 50ms
	TH0 = Time0TH0;
	TL0 = Time0TL0;
	num++;
	if (num > 10)
	{
		LcdShowDistance(GetDistance());
		LcdShow(6, 0);
		LcdWriteData('c');
		LcdWriteData('m');
		num = 0;
	}
}

void Time1Inter() interrupt 3
{
	flag = 1;
}

uint GetDistance()
{
	uint num = 0;
	TH1 = 0;
	TL1 = 0;
	
	Trig = 1;
	for (num=0; num < 15; num++) {
		_nop_();
	}
	Trig = 0;
	while (!Echo);
	TR1 = 1;
	while (Echo && !flag);
	TR1 = 0;
	
	num = (TH1*256 + TL1);
	num = (num*1.7)/100;
	return num;
}

void LcdShowDistance(uint num)
{
	if (flag)
	{
		flag = 0;
		LcdShowString(2, 0, "----");
		return;
	}
	LcdShow(5, 0);
	LcdWriteData(num%10+0x30);
	num /= 10;
	LcdShow(4, 0);
	LcdWriteData(num%10+0x30);
	num /= 10;
	LcdShow(3, 0);
	LcdWriteData(num%10+0x30);
	num /= 10;
	LcdShow(2, 0);
	LcdWriteData(num%10+0x30);
}

