/* Lcd屏驱动 */

#ifndef __LCD1602_H__
#define __LCD1602_H__

#include <reg52.h>

sbit LcdRS = P2^6;
sbit LcdRW = P2^5;
sbit LcdEN = P2^7;

#define LcdDB     P0
#ifndef uchar
	#define uchar unsigned char
#endif // ! uchar
#ifndef uint
	#define uint  unsigned int
#endif // ! uint
// 清屏指令
#ifndef LcdClear 
	#define LcdClear 0x01
#endif

// 如果LCD在忙碌就一直等待
void LcdBusy()
{
	LcdDB = 0xFF;
	LcdRS = 0;
	LcdRW = 1;
	LcdEN = 1;
	while (LcdDB&0x80);
	LcdEN = 0;
}

// LCD写入指令
void LcdWriteCmd(uchar cmd)
{
	LcdBusy();
	LcdRS = 0;
	LcdRW = 0;
	LcdDB = cmd;
	LcdEN = 1;
	LcdEN = 0;
}

/* 初始化Lcd */
void LcdInit()
{
	// 显示模式设置 0x38 表示数据总线为8位，显示两行，每个字符是5*7点阵
	LcdWriteCmd(0x38); 
	// 打开显示开关 0xC 关闭光标
	LcdWriteCmd(0x0C); 
	// 0x06 表示写字符后地址自动+1
	LcdWriteCmd(0x06); 
	// 清屏
	LcdWriteCmd(0x01); 
}

/* 设置光标位置 */
void LcdShow(uchar x, uchar y)
{
	uchar addr;
	if (y) {
		addr = 0x40 + x;
	}
	else {
		addr = 0x00 + x;
	}
	LcdWriteCmd(addr | 0x80);
}

/* 写入要显示的字符(ASCII码) */
void LcdWriteData(uchar dat)
{
	// 判断忙碌
	LcdBusy();
	
	LcdRS = 1;
	LcdRW = 0;
	LcdDB = dat;
	// E脚高脉冲 写入数据
	LcdEN = 1;
	LcdEN = 0;
}

/* 在指定位置显示一个字符串 */
void LcdShowString(uchar x, uchar y, uchar* str)
{
	LcdShow(x, y);
	while (*str != '\0')
		LcdWriteData(*str++);
}

/* fp 要定义的字符位置 CGRAM 自定义字符的位置 如自定义2字符：fp = 2*8 */
void LcdWriteCGRAM(uchar *dat, uchar fp)
{
	uchar i;
	uchar tmp = 0x40 + fp; // 写入CGRAM指令01000000 后面的零替换成写入的地址
	// 一行一行写入一个字符格
	for (i=0; i < 8; i++)
	{
		LcdWriteCmd(tmp+i);
		LcdWriteData(*dat++);
	}
}

#endif // ! __LCD1602_H__

