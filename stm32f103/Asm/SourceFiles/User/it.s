
; �����쳣�жϺ���ϵͳ����ת������ǰ���Զ���ջȫ���Ĵ����������ڷ���ʱ�Զ���ջ

        INCLUDE System/register.s

                AREA    |it|, CODE, READONLY

SysTick_Handler PROC
                EXPORT  SysTick_Handler
                LDR     R0, =0x20000000
                LDR     R1, [R0, #0x04]
                ADDS    R1, #0x01
                ITTT    CS
                LDRCS   R2, [R0, #0x08]
                ADDCS   R2, #0x01
                STRCS   R2, [R0, #0x08]
                STR     R1, [R0, #0x04]
                BX      LR
                ENDP

USART1_IRQHandler\
                PROC
                EXPORT  USART1_IRQHandler
                ; �����ж�
                
                ; ��������ж�
                
                BX      LR
                ENDP

                ALIGN
                END
