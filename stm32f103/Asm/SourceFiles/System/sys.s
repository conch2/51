
        INCLUDE System/register.s

                AREA    |SYSTEM|, CODE, READONLY

; 设置中断优先级分组
; 参数：R0 可选：NVIC_PRIORITYGROUP_0、NVIC_PRIORITYGROUP_1、
;               NVIC_PRIORITYGROUP_2、NVIC_PRIORITYGROUP_3、NVIC_PRIORITYGROUP_4
NVIC_SetPriorityGrouping\
                PROC
                EXPORT  NVIC_SetPriorityGrouping
                PUSH    {R1, R2, LR}
                LDR     R1, =SCB_BASE
                LDR     R2, [R1, #SCB_AIRCR]
                BIC     R2, #0x0F00
                ORR     R2, R0
                ; 高半字写0x05FA
                MOVT    R2, #0x05FA
                STR     R2, [R1, #SCB_AIRCR]
                POP     {R1, R2, PC}
                ENDP

; 参数：R0 I2C基地址
;       R1 数据
;       R2 从机地址
I2C_SendData_8Bit\
                PROC
                EXPORT  I2C_SendData_8Bit
                ; 检测I2C接口是否在忙
I2C_SendData_8Bit_Wait_Busy
                LDR     R3, [R0, #I2C_SR2]
                TSTS    R3, #0x02
                BNE     I2C_SendData_8Bit_Wait_Busy
                ; 产生起始条件，准备开始通讯
                LDR     R3, [R0, #I2C_CR1]
                ORR     R3, #0x0100
                STR     R3, [R0, #I2C_CR1]
                MOV     R3, R1
                ; 检查是否在忙、起始条件是否发送
I2C_SendData_8Bit_Wait_Start
                LDR     R1, =0x00030001
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     I2C_SendData_8Bit_Wait_Start
                ; 发送从机地址
                ORR     R2, #0x01
                STR     R2, [R0, #I2C_DR]
                ; 等待发送地址完成
I2C_SendData_8Bit_SendAddr
                LDR     R1, =I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED
                BL      I2C_CheckEvent
                CBNZ    R7, I2C_SendData_8Bit_SendAddr_EXIT
                B       I2C_SendData_8Bit_SendAddr
I2C_SendData_8Bit_SendAddr_EXIT
                ; 发送数据
                STR     R3, [R0, #I2C_DR]
                BX      LR
                ENDP

; I2C状态寄存器检测
; 参数：R0   I2C基地址
;       R1  检查的值
; 返回值：R7    0不相等
;               1相等
I2C_CheckEvent  PROC
                EXPORT  I2C_CheckEvent
                PUSH    {R2, LR}
                LDRD    R7, R2, [R0, #I2C_SR1]
                BFI.W   R7, R2, #16, #16        ; 将两个状态寄存器合一
                AND     R7, R7, R1
                TEQ     R7, R1
                ITE     EQ
                MOVEQ   R7, #0x01
                MOVNE   R7, #0x00
                POP     {R2, PC}
                ENDP

                ALIGN
                END
