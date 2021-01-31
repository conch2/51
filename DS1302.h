/* DS1302时钟芯片驱动 */

#ifndef __DS1302_H__
#define __DS1302_H__

#include <reg52.h>

#ifndef uint 
	#define uint  unsigned int
#endif // ! uint
#ifndef uchar
	#define uchar unsigned char
#endif // ! uchar
/* 操作指令 */
#define DSRSEC     0x81
#define DSRMIN     0x83
#define DSRHOUR    0x85
#define DSRDAY     0x87
#define DSRMOON    0x89
#define DSRWEEK    0x8B
#define DSRYEAR    0x8D
#define DSRPROTECT 0x8F
#define DSWSEC     0x80
#define DSWMIN     0x82
#define DSWHOUR    0x84
#define DSWDAY     0x86
#define DSWMOON    0x88
#define DSWWEEK    0x8A
#define DSWYEAR    0x8C
/* 写操作保护寄存器的操作值、地址 */
#define DSWPROTECT 0x8E

sbit DS1302IO   = P3^4;
sbit DS1302CE   = P3^5;
sbit DS1302SCLK = P3^6;

/* BCD码格式 */
typedef struct TIME
{
	uchar sec;  // 秒
	uchar min;  // 分钟
	uchar hour; // 小时
	uchar day;  // 天
	uchar moon; // 月份
	uchar week; // 星期
	uchar year;
} Time;

/* 向DS1302写入一个字节 */
void DSWrByte(uchar dat)
{
	uchar i;
	for (i=0; i < 8; i++)
	{
		DS1302IO = dat & 0x01;
		dat >>= 1;
		// 在下降沿DS会读取数据
		DS1302SCLK = 1;
		DS1302SCLK = 0;
	}
}

void DSWrdata(uchar cmd, uchar dat)
{
	DS1302CE = 0;
	DS1302SCLK = 0;
	DS1302CE = 1;
	// 写入命令
	DSWrByte(cmd);
	
	DSWrByte(dat);
	
	DS1302CE = 0;
}

uchar DSReadData(uchar cmd)
{
	uchar i, dat=0;
	
	DS1302CE   = 0;
	DS1302SCLK = 0; // CE至高前SCLK必须是低电平
	DS1302CE   = 1;
	
	DSWrByte(cmd);
	
	for (i=1; i != 0; i<<=1)
	{
		if (DS1302IO != 0)
			dat |= i;
		DS1302SCLK = 1;
		DS1302SCLK = 0;
	}
	
	DS1302CE = 0;
	return dat;
}

void DSReadTime(Time* time)
{
	uchar i;
	uchar* utime = time;
	for (i=0; i<14; i+=2)
	{
		*utime++ = DSReadData(DSRSEC + i);
	}
}

/* 初始化DS的时间 */
void DSInitTime(Time* time)
{
	// 关闭写入保护
	DSWrdata(DSWPROTECT, 0x00);
	DSWrdata(DSWSEC,  time->sec);
	DSWrdata(DSWMIN,  time->min);
	DSWrdata(DSWHOUR, time->hour);
	DSWrdata(DSWDAY,  time->day);
	DSWrdata(DSWWEEK, time->week);
	DSWrdata(DSWMOON, time->moon);
	DSWrdata(DSWYEAR, time->year);
	// 打开保护
	DSWrdata(DSWPROTECT, 0x80);
}

#endif // ! __DS1302_H__

