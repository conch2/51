
        INCLUDE System/register.s

                AREA    |SYSTEM|, CODE, READONLY

; �����ж����ȼ�����
; ������R0 ��ѡ��NVIC_PRIORITYGROUP_0��NVIC_PRIORITYGROUP_1��
;               NVIC_PRIORITYGROUP_2��NVIC_PRIORITYGROUP_3��NVIC_PRIORITYGROUP_4
NVIC_SetPriorityGrouping\
                PROC
                EXPORT  NVIC_SetPriorityGrouping
                PUSH    {R1, R2, LR}
                LDR     R1, =SCB_BASE
                LDR     R2, [R1, #SCB_AIRCR]
                BIC     R2, #0x0F00
                ORR     R2, R0
                ; �߰���д0x05FA
                MOVT    R2, #0x05FA
                STR     R2, [R1, #SCB_AIRCR]
                POP     {R1, R2, PC}
                ENDP

; ������R0 I2C����ַ
;       R1 ����
;       R2 �ӻ���ַ
I2C_SendData_8Bit\
                PROC
                EXPORT  I2C_SendData_8Bit
                ; ���I2C�ӿ��Ƿ���æ
I2C_SendData_8Bit_Wait_Busy
                LDR     R3, [R0, #I2C_SR2]
                TSTS    R3, #0x02
                BNE     I2C_SendData_8Bit_Wait_Busy
                ; ������ʼ������׼����ʼͨѶ
                LDR     R3, [R0, #I2C_CR1]
                ORR     R3, #0x0100
                STR     R3, [R0, #I2C_CR1]
                MOV     R3, R1
                ; ����Ƿ���æ����ʼ�����Ƿ���
I2C_SendData_8Bit_Wait_Start
                LDR     R1, =0x00030001
                BL      I2C_CheckEvent
                TEQ     R7, #0x00
                BEQ     I2C_SendData_8Bit_Wait_Start
                ; ���ʹӻ���ַ
                ORR     R2, #0x01
                STR     R2, [R0, #I2C_DR]
                ; �ȴ����͵�ַ���
I2C_SendData_8Bit_SendAddr
                LDR     R1, =I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED
                BL      I2C_CheckEvent
                CBNZ    R7, I2C_SendData_8Bit_SendAddr_EXIT
                B       I2C_SendData_8Bit_SendAddr
I2C_SendData_8Bit_SendAddr_EXIT
                ; ��������
                STR     R3, [R0, #I2C_DR]
                BX      LR
                ENDP

; I2C״̬�Ĵ������
; ������R0   I2C����ַ
;       R1  ����ֵ
; ����ֵ��R7    0�����
;               1���
I2C_CheckEvent  PROC
                EXPORT  I2C_CheckEvent
                PUSH    {R2, LR}
                LDRD    R7, R2, [R0, #I2C_SR1]
                BFI.W   R7, R2, #16, #16        ; ������״̬�Ĵ�����һ
                AND     R7, R7, R1
                TEQ     R7, R1
                ITE     EQ
                MOVEQ   R7, #0x01
                MOVNE   R7, #0x00
                POP     {R2, PC}
                ENDP

                ALIGN
                END
