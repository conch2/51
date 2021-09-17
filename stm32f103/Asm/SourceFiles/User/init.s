; �����ڸ��ļ����ϵͳ�ĳ�ʼ������
; �����У���ʼ��ϵͳʱ��
;
; �ڶ�(0x20000000)��ŵ�ǰϵͳʱ��Ƶ��

        INCLUDE System/register.s

                AREA    |init|, CODE, READONLY
                
; ϵͳ��ʼ��
SystemInit      PROC
                EXPORT  SystemInit          [WEAK]
                PUSH    {LR}
                ; ��ʼ��ϵͳʱ���
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
                
; ����ϵͳʱ��
; ��PLL������
;   HSE(�ⲿ����ʱ��)������������ϵͳʱ��Ϊ72MHz
;   HSE��������������ϵͳʱ��Ϊ64MHz
; ��0x20000000-0x20000004�����ŵ�ǰϵͳʱ��Ƶ��
SYSCLK_Init     PROC
                EXPORT  SYSCLK_Init         [WEAK]
                LDR     R3, =0x20000000
                ; ��PLL
                LDR     R0, =RCC_BASE
                LDR     R1, [R0, #RCC_CR]
                BIC     R1, #0x01000000
                STR     R1, [R0, #RCC_CR]
                ; ���ⲿ����ʱ��
                LDR     R1, [R0, #RCC_CR]
                ORR     R1, #0x00010000
                STR     R1, [R0, #RCC_CR]
                ; ���HSE�Ƿ�׼������������ĵȴ�ʱ�䲻�˹���
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
                ; ��PLL
                LDR     R1, [R0, #RCC_CR]
                ORR     R1, #0x01000000
                STR     R1, [R0, #RCC_CR]
                ; �ȴ�PLL����
                MOV     R2, #0xFFFF
wait_PLL_be_ready
                LDR     R1, [R0, #RCC_CR]
                TSTS    R1, #0x02000000
                BNE     PLL_OK
                SUBS    R2, #0x01
                BNE     wait_PLL_be_ready
                ; PLLʹ��ʧ��
                ; ���ⲿ���پ���
                B       SYSCLK_Init_Exit
                ; PLLʹ�����
                ; ����Flash
                ; ��Flash������
PLL_OK          LDR     R1, =FLASH_BASE
                LDR     R2, [R1, #FLASH_ACR]
                ORR     R2, #0x10
                STR     R2, [R1, #FLASH_ACR]
                ; Flash 2 wait state ����Flash�����ȴ�����
                LDR     R2, [R1, #FLASH_ACR]
                BIC     R2, #0x03
                STR     R2, [R1, #FLASH_ACR]
                LDR     R2, [R1, #FLASH_ACR]
                ORR     R2, #0x02
                STR     R2, [R1, #FLASH_ACR]
                ; �л�ϵͳʱ��ΪPLL
                LDR     R1, [R0, #RCC_CFGR]
                ORR     R1, #0x02
                STR     R1, [R0, #RCC_CFGR]
SYSCLK_Init_Exit
                ; ����жϱ�־λ��ʱ�Ӱ�ȫϵͳ�жϡ�PLL�����жϡ�HSE�����жϡ�LSE�����жϡ�LSI�����ж�
                MOV     R1, #0x9F0000
                STR     R1, [R0, #RCC_CIR]
                ; ��ϵͳʱ��Ƶ��д��0x20000000
                STR     R4, [R3, #0x00]
                BX      LR
                ENDP
                
; Ĭ�����óɷ���4
NVIC_Init       PROC
                EXPORT  NVIC_Init           [WEAK]
                LDR     R0, =SCB_BASE
                ; ��д��SCB_AIRCR�Ĵ���ʱҪ����16λ���ó�0x05FA�����޷�д��
                LDR     R1, =0x05FA0300
                STR     R1, [R0, #SCB_AIRCR]
                BX      LR
                ENDP
                
; ѡ��ϵͳʱ��HCLK��ΪSysTickʱ��
; Ĭ�����ó�1ms
SysTick_Init    PROC
                EXPORT  SysTick_Init        [WEAK]
                ; ����Systick�ж����ȼ�
                LDR     R0, =SCB_BASE
                MOV     R1, #0x00
                STRB    R1, [R0, #(SCB_SHP+0x0B)]
                ; ������װ��ֵ
                ; Ĭ����0x20000000(4�ֽ�)��ŵ�ǰϵͳʱ��Ƶ�ʣ�������SYSCLK_Init
                LDR     R0, =0x20000000
                LDR     R1, [R0, #0x00]
                MOV     R2, #1000
                UDIV    R1, R2
                SUB     R1, #0x01
                LDR     R0, =SysTick_BASE
                STR     R1, [R0, #SysTick_LOAD]
                ; �����ǰ��ֵ�Ĵ���
                STR     R1, [R0, #SysTick_VAL]
                ; ���ÿ��Ƽ�״̬�Ĵ���
                MOV     R1, #0x06
                STR     R1, [R0, #SysTick_CTRL]
                MOV     R1, #0x07
                STR     R1, [R0, #SysTick_CTRL]
                BX      LR
                ENDP
                
GPIO_Init       PROC
                EXPORT  GPIO_Init           [WEAK]
                PUSH    {R0-R1, LR}
                ; ʹ��GPIOxʱ��
                MOV     R1, #0x1C
                LDR     R0, =RCC_BASE
                STR     R1, [R0, #RCC_APB2ENR]
                ; ����GPIOx_Pin
                LDR     R0, =GPIOA_BASE
                ; ���õͶ˿�0-7
                LDR     R1, [R0, #GPIOx_CRL]
                STR     R1, [R0, #GPIOx_CRL]
                ; ���ø߶˿�8-15
                LDR     R1, [R0, #GPIOx_CRH]
                STR     R1, [R0, #GPIOx_CRH]
                ; ��������
                LDR     R1, [R0, #GPIOx_LCKR]
                STR     R1, [R0, #GPIOx_LCKR]
                POP     {R0-R1, PC}
                ENDP
                
; Usart��ʼ����Ĭ�����ã�
; 8λ���ݣ�1��ֹͣλ����У�飬��CTSE��RTSEӲ��������
; ���ж�
; �����ʣ�115200
Usart_Init      PROC
                EXPORT  Usart_Init
                ; ʹ��GPIOAʱ�Ӻ�Usart1ʱ��
                LDR     R0, =RCC_BASE
                LDR     R1, [R0, #RCC_APB2ENR]
                LDR     R2, =0x4004
                ORR     R1, R2
                STR     R1, [R0, #RCC_APB2ENR]
                ; ����GPIO
                ; ��Ҫ�õ�GPIOA��Pin9(TX)��Pin10(RX)
                ; TX����Ϊ�����������
                ; RX���ø���������������룬��������Ϊ��������
                LDR     R0, =GPIOA_BASE
                LDR     R1, [R0, #GPIOx_CRH]
                BIC     R1, #0x0FF0
                ORR     R1, #0x04B0
                STR     R1, [R0, #GPIOx_CRH]
                ; ����Usart1
                ; ����ֹͣλ��1��ֹͣλ
                LDR     R0, =USART1_BASE
                LDR     R1, [R0, #USART_CR2]
                BIC     R1, #0x3000
                STR     R1, [R0, #USART_CR2]
                ; �����ֳ���8λ���ݡ���У�顢ʹ��TX��RX
                LDR     R0, =USART1_BASE
                LDR     R1, [R0, #USART_CR1]
                LDR     R2, =0x160C
                BIC     R1, R2
                ORR     R1, #0xC
                STR     R1, [R0, #USART_CR1]
                ; ���CTSE��RTSEӲ��������
                LDR     R0, =USART1_BASE
                LDR     R1, [R0, #USART_CR3]
                BIC     R1, #0x0300
                STR     R1, [R0, #USART_CR3]
                ; ���ò����ʣ�Ĭ������Ϊ115200(0x1C200)
                ; ͨ������Tx / Rx ������ �� fPCLKx/��16*USARTDIV����ʽ�ó���������Ϊ39
                ; С��Ϊ0.0625��Ҫ�Ž��Ĵ���ʱ��Ҫx16������С�����ּĴ���ֵΪ0.0625*16=1��
                ; ����д��BRR�Ĵ�����ֵΪ(0x27<<4)|0x1
                LDR     R1, =0x271
                STR     R1, [R0, #USART_BRR]
                ; ʹ��Usart1
                LDR     R1, [R0, #USART_CR1]
                ORR     R1, #0x2000
                STR     R1, [R0, #USART_CR1]
                BX      LR
                ENDP
                
; I2C��ʼ��
I2C_Init        PROC
                EXPORT  I2C_Init
                ; I2C1
                ; ʹ��GPIOB��I2C1ʱ��
                LDR     R0, =RCC_BASE
                LDR     R1, [R0, #RCC_APB2ENR]
                ORR     R1, #0x08
                STR     R1, [R0, #RCC_APB2ENR]
                LDR     R1, [R0, #RCC_APB1ENR]
                ORR     R1, #0x200000
                STR     R1, [R0, #RCC_APB1ENR]
                ; ����GPIO��I2CͨѶGPIO������Ϊ���ÿ�©���
                ; I2C1��ӦGPIOB Pin6(SCL) Pin7(SDA)
                LDR     R0, =GPIOB_BASE
                LDR     R1, [R0, #GPIOx_CRL]
                ORR     R1, R1, #0xFF000000
                STR     R1, [R0, #GPIOx_CRL]
                ; ����I2C�Ĵ���
                LDR     R0, =I2C1_BASE
                ; ����I2C
                LDR     R1, [R0, #I2C_CR1]
                BIC     R1, #0x01
                STR     R1, [R0, #I2C_CR1]
                ; I2Cģ��ʱ��Ƶ�ʣ�36MHz
                LDR     R1, [R0, #I2C_CR2]
                BIC     R1, #0x3F
                ORR     R1, #36             ; 36MHz
                STR     R1, [R0, #I2C_CR2]
                ; �����������ʱ�� Tlow/Thigh = 2  CCR = (PCLK1 / (I2C_ClockSpeed * 3))
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
                ORR     R2, #0x8000         ; ����ģʽ��I2C
                STRH    R2, [R0, #I2C_CCR]
                ; TRISE (PCLK1/1000000 * 3)/10 + 1
                LDR     R3, =1000000
                UDIV    R2, R4, R3
                LDR     R3, =0x03
                MUL     R2, R2, R3
                ADD     R2, #0x01
                STRH    R2, [R0, #I2C_TRISE]
                ; ʹ��I2C
                LDR     R1, [R0, #I2C_CR1]
                ORR     R1, #0x01
                STR     R1, [R0, #I2C_CR1]
                LDR     R2, =0xFBF5
                LDR     R1, [R0, #I2C_CR1]
                ; I2Cģʽ
                AND     R1, R2
                ORR     R1, #0x0400             ; Ӧ��ʹ��
                STR     R1, [R0, #I2C_CR1]
                ; ���������ַ(�������)  7λ��ַģʽ
                ; ��Ҫע���14λ��������Ϊ1
                LDR     R1, =0x40CA
                STR     R1, [R0, #I2C_OAR1]
                BX      LR
                ENDP
                
                ALIGN
                END
