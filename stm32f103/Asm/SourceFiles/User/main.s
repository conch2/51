
        INCLUDE System/register.s

                AREA    |Main Code|, CODE, READONLY
                
                IMPORT  LED_Init
                IMPORT  LED_Set_State
                IMPORT  OLED_Init
                IMPORT  OLED_Refresh_OneTime
                IMPORT  OLED_WriteData

; ������
main            PROC
                EXPORT  main
                
                LDR     R0, =LED_Init
                BLX     R0
                LDR     R0, =OLED_Init
                BLX     R0
                
                LDR     R0, =0x20000400
                LDR     R1, =0x0F0CBDA6
                STR     R1, [R0, #0x04]
                LDR     R1, =0x00
                STR     R1, [R0, #0x08]
                LDR     R1, =0x00
                STR     R1, [R0, #0x0C]
                LDR     R0, =OLED_WriteData
                BLX     R0
                LDR     R0, =I2C1_BASE
                LDR     R1, =0x00
                STR     R1, [R0, #I2C_DR]
;main_Wait_Busy
;                LDR     R3, [R0, #I2C_SR2]
;                TSTS    R3, #0x02
;                BNE     main_Wait_Busy
                LDR     R1, =0x00
                STR     R1, [R0, #I2C_DR]
                
mainloop        LDR     R0, =1000
                LDR     R1, =LED_Set_State
                BL      delay_ms
                LDR     R0, =0x00
                BLX     R1
                LDR     R0, =1000
                BL      delay_ms
                LDR     R0, =0x01
                BLX     R1
                PUSH    {R1}
                LDR     R0, =0x20000000
                LDR     R1, [R0, #0x04]
                LDR     R0, =0x20000400
                STR     R1, [R0, #0x04]
                LDR     R0, =OLED_Refresh_OneTime
                BLX     R0
                POP     {R1}
                B       mainloop
                ENDP
                
; ��ʱ��������λ����
; ������R0 ��ʱ���ٺ���
delay_ms        PROC
                EXPORT  delay_ms
                PUSH    {R1-R4, LR}
                LDR     R1, =SysTimeStamp
                ; ����ǰʱ��+R0��ŵ�R2, R3��
                LDRD    R2, R3, [R1, #0x00]
;                LDR     R3, [R1, #0x04]
;                LDR     R2, [R1, #0x00]
                ADDS    R2, R0
                ADC     R3, #0x00
delay_ms_loop   LDRD    R0, R4, [R1, #0x00]
;                LDR     R0, [R1, #0x00]
;                LDR     R4, [R1, #0x04]
                CMP     R4, R3
                ; �޷��Ŵ���
                BHI     delay_ms_exit
                ; �����ڣ��൱��С�ڣ�
                BNE     delay_ms_loop
                ; ����
                ; �Ƚϵ�32λ
                CMP     R0, R2
                ; �޷��Ŵ��ڵ���
                BCS     delay_ms_exit
                B       delay_ms_loop
delay_ms_exit   POP     {R1-R4, PC}
                ENDP
                
; ������R0:Usart����ַ
;       R1:����
Usart_SendData  PROC
                EXPORT  Usart_SendData
                PUSH    {R2, LR}
                ; �ȴ���һ�����ݷ������
Usart_SendData_Wait
                LDR     R2, [R0, #USART_SR]
                TST     R2, #0x80
                BEQ     Usart_SendData_Wait
                ; ��������
                UBFX    R1, R1, #0, #9      ; ��R1(�ڶ���R1)�ĵ�0λȡ9λ������λ�޷�����չ��R1(��һ��R1)
                STRH    R1, [R0, #USART_DR]
Usart_SendData_Exit
                POP     {R2, PC}
                ENDP
                
                ALIGN
                END
