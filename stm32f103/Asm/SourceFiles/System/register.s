; 该文件主要是对单片机的寄存器地址进行定义

; System Control Space Base Address  核心CM3系统控制空间基址
SCS_BASE        EQU     0xE000E000
ITM_BASE        EQU     0xE0000000

SysTick_BASE    EQU     (SCS_BASE + 0x10)
; SysTick控制及状态寄存器
; 位段 名称       类型 复位值 描述
; 16   COUNTFLAG  R    0     如果在上次读取本寄存器后，SysTick 已经计到了 0，则该位为 1。
;                            如果读取该位，该位将自动清零
; 2    CLKSOURCE  R/W  0     0=外部时钟源(STCLK)
;                            1=内核时钟(FCLK)
; 1    TICKINT    R/W  0     1=SysTick倒数计数到0时产生SysTick异常请求
;                            0=数到 0 时无动作
; 0    ENABLE     R/W  0     SysTick 定时器的使能位
SysTick_CTRL    EQU     0x00
; SysTick重装载数值寄存器
SysTick_LOAD    EQU     0x04
; SysTick当前数值寄存器
SysTick_VAL     EQU     0x08
; SysTick校准数值寄存器
SysTick_CV      EQU     0x0C

; System Control Block Base Address  系统控制块基址
SCB_BASE        EQU     (SCS_BASE + 0x0D00)
; CPU ID寄存器(只读)
SCB_CPUID       EQU     0x00
; Interrupt Control and State Register  中断控制和状态寄存器
SCB_ICSR        EQU     0x04
; Vector Table Offset Register  中断向量表偏移量寄存器
SCB_VTOR        EQU     0x08
; Application Interrupt and Reset Control Register  应用程序中断及复位控制寄存器
SCB_AIRCR       EQU     0x0C
; 系统异常(中断)优先级寄存器阵列
SCB_SHP         EQU     0x18
; System Handler Control and State Register 系统Handler控制及状态寄存器
SCB_SHCSR       EQU     0x24

NVIC_BASE       EQU     (SCS_BASE +  0x0100)

; 闪存存储器接口
FLASH_BASE      EQU     0x40022000
FLASH_ACR       EQU     0x00
FLASH_KEYR      EQU     0x04
FLASH_OPTKEYR   EQU     0x08
FLASH_SR        EQU     0x0C
FLASH_CR        EQU     0x10
FLASH_AR        EQU     0x14
FLASH_OBR       EQU     0x1C
FLASH_WRPR      EQU     0x20

; RCC寄存器基地址
RCC_BASE        EQU     0x40021000
; 时钟控制寄存器
RCC_CR          EQU     0x00
; 时钟配置寄存器
RCC_CFGR        EQU     0x04
; 时钟中断寄存器
RCC_CIR         EQU     0x08
; APB2 外设复位寄存器
RCC_APB2RSTR    EQU     0x0C
; APB1 外设复位寄存器
RCC_APB1RSTR    EQU     0x10
; AHB外设时钟使能寄存器
RCC_AHBENR      EQU     0x14
; APB2 外设时钟使能寄存器
RCC_APB2ENR     EQU     0x18
; APB1 外设时钟使能寄存器
RCC_APB1ENR     EQU     0x1C
; 备份域控制寄存器
RCC_BDCR        EQU     0x20
; 控制/状态寄存器
RCC_CSR         EQU     0x24

; GPIOD寄存器基地址
GPIOD_BASE      EQU     0x40011400
; GPIOC寄存器基地址
GPIOC_BASE      EQU     0x40011000
; GPIOB寄存器基地址
GPIOB_BASE      EQU     0x40010C00
; GPIOA寄存器基地址
GPIOA_BASE      EQU     0x40010800

; 端口配置低寄存器
GPIOx_CRL       EQU     0x00
; 端口配置高寄存器
GPIOx_CRH       EQU     0x04
GPIOx_IDR       EQU     0x08
GPIOx_ODR       EQU     0x0C
GPIOx_BSRR      EQU     0x10
GPIOx_BRR       EQU     0x14
; 端口配置锁定寄存器
GPIOx_LCKR      EQU     0x18

; Usart1 串口1
USART1_BASE     EQU     0x40013800
; 状态寄存器
USART_SR        EQU     0x00
; 数据寄存器
USART_DR        EQU     0x04
; 波特比率寄存器
USART_BRR       EQU     0x08
; 控制寄存器 1
USART_CR1       EQU     0x0C
; 控制寄存器 2
USART_CR2       EQU     0x10
; 控制寄存器 3
USART_CR3       EQU     0x14
; 保护时间和预分频寄存器
USART_GTPR      EQU     0x18

; I2C1
I2C1_BASE       EQU     0x40005400
; I2C控制寄存器 1
I2C_CR1         EQU     0x00
; I2C控制寄存器 2
I2C_CR2         EQU     0x04
; 自身地址寄存器 1
I2C_OAR1        EQU     0x08
; 自身地址寄存器 2
I2C_OAR2        EQU     0x0C
; 数据寄存器
I2C_DR          EQU     0x10
; 状态寄存器 1
I2C_SR1         EQU     0x14
; 状态寄存器 2
I2C_SR2         EQU     0x18
; 时钟控制寄存器
I2C_CCR         EQU     0x1C
; TRISE寄存器
I2C_TRISE       EQU     0x20

I2C_EVENT_MASTER_MODE_SELECT\
                EQU     0x00030001
I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED\
                EQU     0x00070082
I2C_EVENT_MASTER_BYTE_TRANSMITTED\
                EQU     0x00070084

; 系统时间，单位毫秒，8字节
SysTimeStamp    EQU     0x20000004

; 中断优先级组0：0Bit抢占优先级 4Bit子优先级
NVIC_PRIORITYGROUP_0\
                EQU     0x0700
; 中断优先级组1：1Bit抢占优先级 3Bit子优先级
NVIC_PRIORITYGROUP_1\
                EQU     0x0600
; 中断优先级组2：2Bit抢占优先级 2Bit子优先级
NVIC_PRIORITYGROUP_2\
                EQU     0x0500
; 中断优先级组3：3Bit抢占优先级 1Bit子优先级
NVIC_PRIORITYGROUP_3\
                EQU     0x0400
; 中断优先级组4：4Bit抢占优先级 0Bit子优先级
NVIC_PRIORITYGROUP_4\
                EQU     0x0300

                END
