; 程序在该文件完成系统的初始化工作
; 具体有：初始化系统时钟
;
; 在堆(0x20000000)存放当前系统时钟频率

        INCLUDE System/register.s

                AREA    |init|, CODE, READONLY
                
; 系统初始化
SystemInit      PROC
                EXPORT  SystemInit          [WEAK]
                PUSH    {LR}
                ; 初始化系统时间戳
                LDR     R0, =0x20000000
                MOV     R1, #0x00
                STR     R1, [R0, #0x04]
                STR     R1, [R0, #0x08]
                BL      SYSCLK_Init
                BL      NVIC_Init
                BL      SysTick_Init
                BL      GPIO_Init
                BL      Usart_Init
                BL      I2C_Init
                POP     {PC}
                ENDP
                
; 配置系统时钟
; 若PLL正常：
;   HSE(外部高速时钟)正常，则配置系统时钟为72MHz
;   HSE不正常，则配置系统时钟为64MHz
; 在0x20000000-0x20000004处会存放当前系统时钟频率
SYSCLK_Init     PROC
                EXPORT  SYSCLK_Init         [WEAK]
                LDR     R3, =0x20000000
                ; 关PLL
                LDR     R0, =RCC_BASE
                LDR     R1, [R0, #RCC_CR]
                BIC     R1, #0x01000000
                STR     R1, [R0, #RCC_CR]
                ; 开外部高速时钟
                LDR     R1, [R0, #RCC_CR]
                ORR     R1, #0x00010000
                STR     R1, [R0, #RCC_CR]
                ; 检查HSE是否准备就绪，这里的等待时间不宜过短
                LDR     R2, =0xFFFF
SYSCLK_Init_wait_HSE_OK
                LDR     R1, [R0, #RCC_CR]
                TSTS    R1, #0x00020000
                BNE     SYSCLK_Init_HSE_OK
                SUBS    R2, #0x01
                BEQ     SYSCLK_Init_HSE_ERROR
                B       SYSCLK_Init_wait_HSE_OK
SYSCLK_Init_HSE_OK
                LDR     R4, =72000000
                LDR     R1, =0x1D0400
                B       RCC_CFGR_P_OK
SYSCLK_Init_HSE_ERROR
                LDR     R4, =64000000
                LDR     R1, =0x3C0400
RCC_CFGR_P_OK   STR     R1, [R0, #RCC_CFGR]
                ; 打开PLL
                LDR     R1, [R0, #RCC_CR]
                ORR     R1, #0x01000000
                STR     R1, [R0, #RCC_CR]
                ; 等待PLL就绪
                MOV     R2, #0xFFFF
wait_PLL_be_ready
                LDR     R1, [R0, #RCC_CR]
                TSTS    R1, #0x02000000
                BNE     PLL_OK
                SUBS    R2, #0x01
                BNE     wait_PLL_be_ready
                ; PLL使能失败
                ; 关外部高速晶振
                B       SYSCLK_Init_Exit
                ; PLL使能完成
                ; 配置Flash
                ; 打开Flash缓冲区
PLL_OK          LDR     R1, =FLASH_BASE
                LDR     R2, [R1, #FLASH_ACR]
                ORR     R2, #0x10
                STR     R2, [R1, #FLASH_ACR]
                ; Flash 2 wait state 设置Flash两个等待周期
                LDR     R2, [R1, #FLASH_ACR]
                BIC     R2, #0x03
                STR     R2, [R1, #FLASH_ACR]
                LDR     R2, [R1, #FLASH_ACR]
                ORR     R2, #0x02
                STR     R2, [R1, #FLASH_ACR]
                ; 切换系统时钟为PLL
                LDR     R1, [R0, #RCC_CFGR]
                ORR     R1, #0x02
                STR     R1, [R0, #RCC_CFGR]
SYSCLK_Init_Exit
                ; 清除中断标志位：时钟安全系统中断、PLL就绪中断、HSE就绪中断、LSE就绪中断、LSI就绪中断
                MOV     R1, #0x9F0000
                STR     R1, [R0, #RCC_CIR]
                ; 将系统时钟频率写如0x20000000
                STR     R4, [R3, #0x00]
                BX      LR
                ENDP
                
; 默认配置成分组4
NVIC_Init       PROC
                EXPORT  NVIC_Init           [WEAK]
                LDR     R0, =SCB_BASE
                ; 在写入SCB_AIRCR寄存器时要将高16位设置成0x05FA否则无法写入
                LDR     R1, =0x05FA0300
                STR     R1, [R0, #SCB_AIRCR]
                BX      LR
                ENDP
                
; 选择系统时钟HCLK作为SysTick时钟
; 默认配置成1ms
SysTick_Init    PROC
                EXPORT  SysTick_Init        [WEAK]
                ; 设置Systick中断优先级
                LDR     R0, =SCB_BASE
                MOV     R1, #0x00
                STRB    R1, [R0, #(SCB_SHP+0x0B)]
                ; 设置重装载值
                ; 默认在0x20000000(4字节)存放当前系统时钟频率，具体在SYSCLK_Init
                LDR     R0, =0x20000000
                LDR     R1, [R0, #0x00]
                MOV     R2, #1000
                UDIV    R1, R2
                SUB     R1, #0x01
                LDR     R0, =SysTick_BASE
                STR     R1, [R0, #SysTick_LOAD]
                ; 清除当前数值寄存器
                STR     R1, [R0, #SysTick_VAL]
                ; 配置控制及状态寄存器
                MOV     R1, #0x06
                STR     R1, [R0, #SysTick_CTRL]
                MOV     R1, #0x07
                STR     R1, [R0, #SysTick_CTRL]
                BX      LR
                ENDP
                
GPIO_Init       PROC
                EXPORT  GPIO_Init           [WEAK]
                PUSH    {R0-R1, LR}
                ; 使能GPIOx时钟
                MOV     R1, #0x1C
                LDR     R0, =RCC_BASE
                STR     R1, [R0, #RCC_APB2ENR]
                ; 配置GPIOx_Pin
                LDR     R0, =GPIOA_BASE
                ; 配置低端口0-7
                LDR     R1, [R0, #GPIOx_CRL]
                STR     R1, [R0, #GPIOx_CRL]
                ; 配置高端口8-15
                LDR     R1, [R0, #GPIOx_CRH]
                STR     R1, [R0, #GPIOx_CRH]
                ; 锁定配置
                LDR     R1, [R0, #GPIOx_LCKR]
                STR     R1, [R0, #GPIOx_LCKR]
                POP     {R0-R1, PC}
                ENDP
                
; Usart初始化，默认配置：
; 8位数据，1个停止位，无校验，无CTSE、RTSE硬件流控制
; 无中断
; 波特率：115200
Usart_Init      PROC
                EXPORT  Usart_Init
                ; 使能GPIOA时钟和Usart1时钟
                LDR     R0, =RCC_BASE
                LDR     R1, [R0, #RCC_APB2ENR]
                LDR     R2, =0x4004
                ORR     R1, R2
                STR     R1, [R0, #RCC_APB2ENR]
                ; 配置GPIO
                ; 需要用到GPIOA的Pin9(TX)和Pin10(RX)
                ; TX配置为复用推挽输出
                ; RX配置浮空输入或上拉输入，这里设置为浮空输入
                LDR     R0, =GPIOA_BASE
                LDR     R1, [R0, #GPIOx_CRH]
                BIC     R1, #0x0FF0
                ORR     R1, #0x04B0
                STR     R1, [R0, #GPIOx_CRH]
                ; 配置Usart1
                ; 设置停止位：1个停止位
                LDR     R0, =USART1_BASE
                LDR     R1, [R0, #USART_CR2]
                BIC     R1, #0x3000
                STR     R1, [R0, #USART_CR2]
                ; 设置字长：8位数据、无校验、使能TX，RX
                LDR     R0, =USART1_BASE
                LDR     R1, [R0, #USART_CR1]
                LDR     R2, =0x160C
                BIC     R1, R2
                ORR     R1, #0xC
                STR     R1, [R0, #USART_CR1]
                ; 清除CTSE、RTSE硬件流控制
                LDR     R0, =USART1_BASE
                LDR     R1, [R0, #USART_CR3]
                BIC     R1, #0x0300
                STR     R1, [R0, #USART_CR3]
                ; 设置波特率，默认配置为115200(0x1C200)
                ; 通过计算Tx / Rx 波特率 ＝ fPCLKx/（16*USARTDIV）公式得出整数部分为39
                ; 小数为0.0625但要放进寄存器时还要x16，所以小数部分寄存器值为0.0625*16=1，
                ; 所以写入BRR寄存器的值为(0x27<<4)|0x1
                LDR     R1, =0x271
                STR     R1, [R0, #USART_BRR]
                ; 使能Usart1
                LDR     R1, [R0, #USART_CR1]
                ORR     R1, #0x2000
                STR     R1, [R0, #USART_CR1]
                BX      LR
                ENDP
                
; I2C初始化
I2C_Init        PROC
                EXPORT  I2C_Init
                ; I2C1
                ; 使能GPIOB、I2C1时钟
                LDR     R0, =RCC_BASE
                LDR     R1, [R0, #RCC_APB2ENR]
                ORR     R1, #0x08
                STR     R1, [R0, #RCC_APB2ENR]
                LDR     R1, [R0, #RCC_APB1ENR]
                ORR     R1, #0x200000
                STR     R1, [R0, #RCC_APB1ENR]
                ; 设置GPIO，I2C通讯GPIO需设置为复用开漏输出
                ; I2C1对应GPIOB Pin6(SCL) Pin7(SDA)
                LDR     R0, =GPIOB_BASE
                LDR     R1, [R0, #GPIOx_CRL]
                ORR     R1, R1, #0xFF000000
                STR     R1, [R0, #GPIOx_CRL]
                ; 配置I2C寄存器
                LDR     R0, =I2C1_BASE
                ; 禁用I2C
                LDR     R1, [R0, #I2C_CR1]
                BIC     R1, #0x01
                STR     R1, [R0, #I2C_CR1]
                ; I2C模块时钟频率，36MHz
                LDR     R1, [R0, #I2C_CR2]
                BIC     R1, #0x3F
                ORR     R1, #36             ; 36MHz
                STR     R1, [R0, #I2C_CR2]
                ; 配置最大上升时间 Tlow/Thigh = 2  CCR = (PCLK1 / (I2C_ClockSpeed * 3))
                LDR     R1, =0x20000000
                LDR     R4, [R1, #0x00]
                LDR     R3, =0x02
                UDIV    R4, R4, R3
                LDR     R3, =(400000*3)
                UDIV    R2, R4, R3
                MOV     R3, #0x0FFF
                TST     R2, R3
                IT      EQ
                ADDEQ   R2, #0x01
                ORR     R2, #0x8000         ; 快速模式的I2C
                STRH    R2, [R0, #I2C_CCR]
                ; TRISE (PCLK1/1000000 * 3)/10 + 1
                LDR     R3, =1000000
                UDIV    R2, R4, R3
                LDR     R3, =0x03
                MUL     R2, R2, R3
                ADD     R2, #0x01
                STRH    R2, [R0, #I2C_TRISE]
                ; 使能I2C
                LDR     R1, [R0, #I2C_CR1]
                ORR     R1, #0x01
                STR     R1, [R0, #I2C_CR1]
                LDR     R2, =0xFBF5
                LDR     R1, [R0, #I2C_CR1]
                ; I2C模式
                AND     R1, R2
                ORR     R1, #0x0400             ; 应答使能
                STR     R1, [R0, #I2C_CR1]
                ; 设置自身地址(随便设置)  7位地址模式
                ; 需要注意第14位必须设置为1
                LDR     R1, =0x40CA
                STR     R1, [R0, #I2C_OAR1]
                BX      LR
                ENDP
                
                ALIGN
                END
