/* 数码管驱动程序 */

#ifndef __DIGITALTUBE_H__
#define __DIGITALTUBE_H__

#include <reg52.h>

#ifndef uchar
	#define uchar unsigned char
#endif // ! uchar
// 数码管数量
#ifndef DTNumbar
	#define DTNumbar 4
#endif // ! DTNumbar
#ifndef DTSwitch
	#define DTSwitch P1
#endif // ! DTSwitch
// 数据脚
#ifndef DTDataAddr
	#define DTDataAddr P0
#endif // ! DTDataAddr
#ifndef DTTrueNumSize
	#define DTTrueNumSize 11
#endif // ! DTTrueNumSize

/* 共阴数码管真值表                     0     1     2     3     4     5     6     7     8     9     .  */
uchar code DTTrueNum[DTTrueNumSize] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x80};

/* * * * * * * 函数声明 * * * * * */
/* * * 数码管初始化 * * */
void DTInit()
{
	DTSwitch &= 0xF0;
}

/* * * * 显示数值 * * * */
/* 参数说明：
 * uchar SEAT:   在第几个显示(从0开始)
 * uchar NUMBER: 显示的内容
 * bit ShowDem:  是否显示小数点 */
void DTShowNum(uchar SEAT, uchar NUMBER, bit ShowDem)
{
	// 输入不规范
	if (NUMBER > 0x09)
		return;
	SEAT = 0x01 << SEAT;
	DTInit();
	DTSwitch |= SEAT;
	
	if (ShowDem) {
		DTDataAddr = DTTrueNum[NUMBER] | DTTrueNum[DTTrueNumSize-1];
	}
	else {
		DTDataAddr = DTTrueNum[NUMBER];
	}
}

#endif // ! __DIGITALTUBE_H__
