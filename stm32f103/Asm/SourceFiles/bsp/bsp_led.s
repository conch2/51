; �������ϵ�LED�Ƶİ弶֧�ְ�

        INCLUDE System/register.s

                AREA    |BSP|, CODE, READONLY
                
; GPIOC Pin13
; �޲������޷���ֵ
LED_Init        PROC
                EXPORT  LED_Init
                PUSH    {R0, R1, LR}
                LDR     R0, =GPIOC_BASE
                LDR     R1, [R0, #GPIOx_CRH]
                BIC     R1, #0xF00000
                ORR     R1, #0x300000
                STR     R1, [R0, #GPIOx_CRH]
                LDR     R1, [R0, #GPIOx_LCKR]
                ORR     R1, #0x02000
                STR     R1, [R0, #GPIOx_LCKR]
                POP     {R0, R1, PC}
                ENDP
                
; R0Ϊ������R0=0 LED�ر� R0!=0LED��
LED_Set_State   PROC
                EXPORT  LED_Set_State
                PUSH    {R1-R2, LR}
                LDR     R1, =GPIOC_BASE
                CMP     R0, #0x00
                ITE     EQ
                MOVEQ   R2, #0x2000
                MOVNE   R2, #0x20000000
                STR     R2, [R1, #GPIOx_BSRR]
                POP     {R1-R2, PC}
                ENDP
                
                ALIGN
                END
