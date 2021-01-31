/* 
	OLED12864 驱动芯片 SSD1306 (IIC接口) 的驱动程序
	硬件接口：
	GND  电源地
	VCC  接5V或3.3V电源
	SCL  STC89C52 --> P10
	SDA  STC89C52 --> P11
 */

#ifndef __OLED12864_DRV_H__
#define __OLED12864_DRV_H__

#include <reg52.h>

#ifndef true
#define true         1
#endif // ! true 

#ifndef false
#define false        0
#endif // ! false 

#ifndef uint8_t
#define uint8_t      unsigned char
#endif // ! uint8_t 

#ifndef uint16_t
#define uint16_t     unsigned int
#endif // ! uint16_t 

#ifndef HIGH
#define HIGH         1
#endif // ! HIGH

#ifndef LOW
#define LOW          0
#endif // ! LOW

#define OLED_SCL(x)  OLED_SCL = x;
#define OLED_SDA(x)  OLED_SDA = x;

sbit OLED_SCL  =     P1^0;
sbit OLED_SDA  =     P1^1;

/*************************************************
	函数名：OLED_Delay_us
	功  能：微妙延迟
	参  数：Count --- 次数
	返回值：void
 *************************************************/
void OLED_Delay_us( uint16_t Count )
{
	while (Count--);
}

/*************************************************
	函数名：OLED_Write_Byte
	功  能：向OLED12864(IIC)写一个字节
	参  数：Byte --- 数据
	返回值：void
 *************************************************/
void OLED_Write_Byte( uint8_t Byte )
{
	
}

/*************************************************
	函数名：OLED_Write_Cmd
	功  能：向OLED12864(IIC)写入一个指令
	参  数：Cmd --- 指令
	返回值：void
 *************************************************/
void OLED_Write_Cmd( uint8_t Cmd )
{
	
}

void OLED_Write_Data( uint8_t Data )
{
	
}

#endif // ! __OLED12864_DRV_H__
