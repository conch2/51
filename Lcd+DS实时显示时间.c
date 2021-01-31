
#include "DS1302.h"
#include "Lcd1602.h"

#define Time0TH0 177  // (65536-20000)/256
#define Time0TL0 224  // (65536-20000)%256

Time _time = {0x10, 0x51, 0x03, 0x27, 0x01, 0x03, 0x21};

uchar date[] = "20xx/xx/xx x";
uchar thistime[] = "xx:xx:xx";

void Init();
void LcdShowTime();

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
	// 初始化DS1302
	DSInitTime(&_time);
	// 初始化Lcd1602
	LcdInit();
	
	// 总中断打开
	EA = 1;
	// 打开定时器0
	TMOD &= 0xF0;
	TMOD |= 0x01;
	// 20ms
	TH0 = Time0TH0;
	TL0 = Time0TL0;
	// 允许定时器0中断
	ET0 = 1;
	// 定时器0开始计时
	TR0 = 1;
}

void Time0Inter() interrupt 1
{
	static uchar num=0;
	// 20ms
	TH0 = Time0TH0;
	TL0 = Time0TL0;
	num++;
	if (num >= 50)
	{
		// 读取当前时间
		DSReadTime(&_time);
		// 在Lcd1602显示
		LcdShowTime();
		num = 0;
	}
}

void LcdShowTime()
{
	date[3] = (_time.year & 0x0F) + 0x30;
	date[2] = ((_time.year & 0xF0) >> 4) + 0x30;
	date[6] = (_time.moon & 0x0F) + 0x30;
	date[5] = ((_time.moon & 0xF0) >> 4) + 0x30;
	date[9] = (_time.day & 0x0F) + 0x30;
	date[8] = ((_time.day & 0xF0) >> 4) + 0x30;
	date[11] = (_time.week & 0x0F) + 0x30;
	thistime[7] = (_time.sec & 0x0F) + 0x30;
	thistime[6] = ((_time.sec & 0x70) >> 4) + 0x30;
	thistime[4] = (_time.min & 0x0F) + 0x30;
	thistime[3] = ((_time.min & 0x70) >> 4) + 0x30;
	thistime[1] = (_time.hour & 0x0F) + 0x30;
	thistime[0] = ((_time.hour & 0x30) >> 4) + 0x30;
	LcdShowString(3, 0, thistime);
	LcdShowString(2, 1, date);
}

