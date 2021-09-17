
        INCLUDE System/register.s

                IMPORT  __initial_sp

; OLED的地址
OLED_ADDRESS    EQU     0x78

OLED_GRAM_SIZE  EQU     0x0400      ; 1KB
OLED_GRAM_BASE  EQU     0x20000400

                AREA    |OLED Init Cmd Data|, DATA, READONLY
OLED_Init_Cmd_Data_Base
                DCB     0xAE            ; display off
                DCB     0x20            ; Set Memory Addressing Mode
                DCB     0x00            ; 0x00,Horizontal Addressing Mode; 0x01,Vertical Addressing Mode; 0x02,Page Addressing Mode (RESET); 0x03,Invalid
                                        ; 0x00 水平地址模式
                DCB     0xB0            ; Set Page Start Address for Page Addressing Mode,0-7
                DCB     0xC8            ; Set COM Output Scan Direction
                DCB     0x00            ; ---set low column address
                DCB     0x10            ; ---set high column address
                DCB     0x40            ; --set start line address
                DCB     0x81            ; --set contrast control register
                DCB     0xFF            ; 亮度调节 0x00~0xff
                DCB     0xA1            ; --set segment re-map 0 to 127
                DCB     0xA6            ; --set normal display
                DCB     0xA8            ; --set multiplex ratio(1 to 64)
                DCB     0x3F            ; 
                DCB     0xA4            ; 0xa4,Output follows RAM content;0xa5,Output ignores RAM content
                DCB     0xD3            ; -set display offset
                DCB     0x00            ; -not offset
                DCB     0xD5            ; --set display clock divide ratio/oscillator frequency
                DCB     0xF0            ; --set divide ratio
                DCB     0xD9            ; --set pre-charge period
                DCB     0x22            ; 
                DCB     0xDA            ; --set com pins hardware configuration
                DCB     0x12            ; 
                DCB     0xDB            ; --set vcomh
                DCB     0x20            ; 0x20,0.77xVcc
                DCB     0x8D            ; --set DC-DC enable
                DCB     0x14            ; 
                DCB     0xAF            ; --turn on oled panel
OLED_Init_Cmd_Data_End
OLED_Init_Cmd_Data_Size\
                EQU     OLED_Init_Cmd_Data_End - OLED_Init_Cmd_Data_Base

                EXPORT  OLED_GRAM_SIZE
                EXPORT  OLED_GRAM_BASE

                AREA    |BSP|, CODE, READONLY

                IMPORT  I2C_CheckEvent

; OLED初始化
OLED_Init       PROC
                EXPORT  OLED_Init
                PUSH    {R0-R3, LR}
                LDR     R0, =OLED_Init_Cmd_Data_Base
                LDR     R2, =OLED_Init_Cmd_Data_Size
                LDR     R3, =0x00
load_cmd        LDR     R1, [R0, R3]
                BL      OLED_WriteCmd
                ADD     R3, #0x01
                TEQ     R2, R3
                BNE     load_cmd
                POP     {R0-R3, PC}
                ENDP

; 参数：R1 要发送的指令
OLED_WriteCmd   PROC
                EXPORT  OLED_WriteCmd
                PUSH    {R0, LR}
                MOV     R0, #0x00
                BL      OLED_I2C_SendData
                POP     {R0, PC}
                ENDP

; 参数：R1 要发送的数据
OLED_WriteData  PROC
                EXPORT  OLED_WriteData
                PUSH    {R0, LR}
                MOV     R0, #0x40
                BL      OLED_I2C_SendData
                POP     {R0, PC}
                ENDP

; 参数：R0 寄存器地址
;       R1 数据
OLED_I2C_SendData\
                PROC
                PUSH    {R2-R3, R7, LR}
                PUSH    {R1}
                CPY     R2, R0
                LDR     R0, =I2C1_BASE
                ; 检测I2C接口是否在忙
OLED_I2C_SendData_Wait_Busy
                LDR     R3, [R0, #I2C_SR2]
                TSTS    R3, #0x02
                BNE     OLED_I2C_SendData_Wait_Busy
                ; 产生起始条件，准备开始通讯
                LDR     R3, [R0, #I2C_CR1]
                ORR     R3, #0x0100
                STR     R3, [R0, #I2C_CR1]
                ; 检查是否在忙、起始条件是否发送
                LDR     R1, =I2C_EVENT_MASTER_MODE_SELECT
OLED_I2C_SendData_Wait_Start
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     OLED_I2C_SendData_Wait_Start
                ; 发送从机地址
                LDR     R3, =0x78
                STR     R3, [R0, #I2C_DR]
                ; 等待发送地址完成
                LDR     R1, =I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED
OLED_I2C_SendData_SendAddr
                BL      I2C_CheckEvent
                CBNZ    R7, OLED_I2C_SendData_SendAddr_EXIT
                B       OLED_I2C_SendData_SendAddr
OLED_I2C_SendData_SendAddr_EXIT
                ; 发送寄存器地址
                STR     R2, [R0, #I2C_DR]
                ; 等待发送完成
                LDR     R1, =I2C_EVENT_MASTER_BYTE_TRANSMITTED
OLED_I2C_SendData_Wait_SendAddr
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     OLED_I2C_SendData_Wait_SendAddr
                ; 发送数据
                POP     {R1}
                STR     R1, [R0, #I2C_DR]
                ; 等待发送完成
                LDR     R1, =I2C_EVENT_MASTER_BYTE_TRANSMITTED
OLED_I2C_SendData_Wait_SendData
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     OLED_I2C_SendData_Wait_SendData
                ; 停止I2C
                LDR     R3, [R0, #I2C_CR1]
                ORR     R3, #0x0200
                STR     R3, [R0, #I2C_CR1]
                POP     {R2-R3, R7, PC}
                ENDP

OLED_Refresh_OneTime\
                PROC
                EXPORT  OLED_Refresh_OneTime
                PUSH    {LR}
                LDR     R0, =I2C1_BASE
                ; 检测I2C接口是否在忙
OLED_Refresh_OneTime_Wait_Busy
                LDR     R3, [R0, #I2C_SR2]
                TSTS    R3, #0x02
                BNE     OLED_Refresh_OneTime_Wait_Busy
                ; 产生起始条件，准备开始通讯
                LDR     R3, [R0, #I2C_CR1]
                ORR     R3, #0x0100
                STR     R3, [R0, #I2C_CR1]
                ; 检查是否在忙、起始条件是否发送
                LDR     R1, =I2C_EVENT_MASTER_MODE_SELECT
OLED_Refresh_OneTime_Wait_Start
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     OLED_Refresh_OneTime_Wait_Start
                ; 发送从机地址
                LDR     R3, =0x78
                STR     R3, [R0, #I2C_DR]
                ; 等待发送地址完成
                LDR     R1, =I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED
OLED_Refresh_OneTime_SendAddr
                BL      I2C_CheckEvent
                CBNZ    R7, OLED_Refresh_OneTime_SendAddr_EXIT
                B       OLED_Refresh_OneTime_SendAddr
OLED_Refresh_OneTime_SendAddr_EXIT
                ; 发送寄存器地址
                LDR     R2, =0x40
                STR     R2, [R0, #I2C_DR]
                ; 等待发送完成
                LDR     R1, =I2C_EVENT_MASTER_BYTE_TRANSMITTED
OLED_Refresh_OneTime_Wait_SendAddr
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     OLED_Refresh_OneTime_Wait_SendAddr
                LDR     R4, =OLED_GRAM_BASE
                LDR     R1, =I2C_EVENT_MASTER_BYTE_TRANSMITTED
                LDR     R2, =0x00
                B       OLED_Refresh_OneTime_Loop_Cond1
OLED_Refresh_OneTime_Loop1
                LDR     R5, [R4, R2, LSL #2]
                LDR     R3, =0x00
OLED_Refresh_OneTime_Loop2
                CMP     R3, #0x04
                BCS     OLED_Refresh_OneTime_Loop2_Exit
                STRH    R5, [R0, #I2C_DR]
                LSR     R5, #0x08
                ; 等待发送完成
OLED_Refresh_OneTime_Wait_SendData
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     OLED_Refresh_OneTime_Wait_SendData
                ADD     R3, #0x01
                B       OLED_Refresh_OneTime_Loop2
OLED_Refresh_OneTime_Loop2_Exit
                ADD     R2, #0x01
OLED_Refresh_OneTime_Loop_Cond1
                CMP     R2, #(0x0100 - 1)
                BLS     OLED_Refresh_OneTime_Loop1      ; 无符号数小于等于
                ; 停止I2C
                LDR     R3, [R0, #I2C_CR1]
                ORR     R3, #0x0200
                STR     R3, [R0, #I2C_CR1]
                POP     {PC}
                ENDP

                ALIGN
                END