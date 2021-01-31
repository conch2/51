/* EEPROM驱动，STC89c52有2KB的EEPROM，一共分为8个扇区，
 * 每个扇区为512字节，建议在写程序时，将同一次修改的数据放在同一个扇区，方便修改，
 * 因为在执行擦除命令时，一次最少要擦除一个扇区的数据，每次在更新数据前都必须要擦除原数据方可重新写入新数据，
 * 不能直接在原来数据基础上更新内容。*/

#ifndef __EEPROM_H__
#define __EEPROM_H__

#include <reg52.h>

#ifndef uint
	#define uint  unsigned int
#endif // ! uint
#ifndef uchar
	#define uchar unsigned char
#endif // ! uchar
#define RdCommand          0x01
#define PrgCommand         0x02
#define EraseCommand       0x03
#define Ok                 0x00
#define Error              0x01
#ifndef WaitTime
	#define WaitTime       0x01 //定义CPU的等待时间
#endif // ! WaitTime

/* Flash数据寄存器。ISP/IAP从Flash读出的数据放在此处，向Flash写入的数据也需放在此处。 */
sfr ISP_DATA  = 0xE2;
/* Flash高字节地址寄存器。ISP/IAP操作时的地址寄存器高八位。 */
sfr ISP_ADDRH = 0xE3;
/* Flash低字节地址寄存器。ISP/IAP操作时的地址寄存器低八位。 */
sfr ISP_ADDRL = 0xE4;
/* Flash命令模式寄存器。ISP/IAP操作时的命令模式寄存器，须命令触发寄存器触发方可生效。 */
/* 0x00待机模式，无ISP操作 0x01对用户的应用程序flash区及数据flash区字节读 
 * 0x02对用户的应用程序flash区及数据flash区字节编程 0x03对用户的应用程序flash区及数据flash区扇区擦除 */
sfr ISP_CMD   = 0xE5;
/* Flash命令触发寄存器，ISP/IAP操作时的命令触发寄存器。
 * 在ISPEN(ISP_CONTR.7)=1时，对ISP_TRIG 先写入46h，再写入B9h，ISP/IAP命令才会生效。 */
sfr ISP_TRIG  = 0xE6;
/* ISP/IAP 控制寄存器 */
sfr ISP_CONTR = 0xE7;

sbit dula = P2^6; //申明U1锁存器的锁存端
sbit wela = P2^7; //申明U2锁存器的锁存端

/* ================ 打开 ISP,IAP 功能 ================= */
void ISP_IAP_enable()
{
	EA = 0;       /* 关中断 */
	ISP_CONTR = ISP_CONTR & 0x18;       /* 0001,1000*/
	ISP_CONTR = ISP_CONTR | WaitTime; /* 写入硬件延时 */
	ISP_CONTR = ISP_CONTR | 0x80;       /* ISPEN=1  */
}

/* =============== 关闭 ISP,IAP 功能 ================== */
void ISP_IAP_disable()
{
	ISP_CONTR = ISP_CONTR & 0x7F; /* ISPEN = 0 */
	ISP_TRIG = 0x00;
	EA   =  1;   /* 开中断 */
}

/* ================ 公用的触发代码 ==================== */
void ISPgoon()
{
	ISP_IAP_enable();   /* 打开 ISP,IAP 功能 */
	ISP_TRIG = 0x46;  /* 触发ISP_IAP命令字节1 */
	ISP_TRIG = 0xB9;  /* 触发ISP_IAP命令字节2 */
}

/* ==================== 字节读 ======================== */
unsigned char byte_read(unsigned int byte_addr)
{
	ISP_ADDRH = (unsigned char)(byte_addr >> 8);/* 地址赋值 */
	ISP_ADDRL = (unsigned char)(byte_addr & 0x00FF);
	ISP_CMD   = ISP_CMD & 0xF8;   /* 清除低3位  */
	ISP_CMD   = ISP_CMD | RdCommand; /* 写入读命令 */
	ISPgoon();       /* 触发执行  */
	ISP_IAP_disable();    /* 关闭ISP,IAP功能 */
	return(ISP_DATA);    /* 返回读到的数据 */
}

/* ==================== 字节写 ======================== */
void byte_write(unsigned int byte_addr, unsigned char original_data)
{
	ISP_ADDRH = (unsigned char)(byte_addr >> 8); /* 取地址  */
	ISP_ADDRL = (unsigned char)(byte_addr & 0x00FF);
	ISP_CMD   = ISP_CMD & 0xF8;    /* 清低3位 */
	ISP_CMD   = ISP_CMD | PrgCommand;  /* 写命令2 */
	ISP_DATA  = original_data;   /* 写入数据准备 */
	ISPgoon();       /* 触发执行  */
	ISP_IAP_disable();     /* 关闭IAP功能 */
}

/* ================== 扇区擦除 ======================== */
void SectorErase(unsigned int sector_addr)
{
	unsigned int iSectorAddr;
	iSectorAddr = (sector_addr & 0xFE00); /* 取扇区地址 */
	ISP_ADDRH   = (unsigned char)(iSectorAddr >> 8);
	ISP_ADDRL   = 0x00;
	ISP_CMD     = ISP_CMD & 0xF8;   /* 清空低3位  */
	ISP_CMD     = ISP_CMD | EraseCommand; /* 擦除命令3  */
	ISPgoon();       /* 触发执行  */
	ISP_IAP_disable();    /* 关闭ISP,IAP功能 */
}

#endif // ! __EEPROM_H__
