; ���ļ���Ҫ�ǶԵ�Ƭ���ļĴ�����ַ���ж���

; System Control Space Base Address  ����CM3ϵͳ���ƿռ��ַ
SCS_BASE        EQU     0xE000E000
ITM_BASE        EQU     0xE0000000

SysTick_BASE    EQU     (SCS_BASE + 0x10)
; SysTick���Ƽ�״̬�Ĵ���
; λ�� ����       ���� ��λֵ ����
; 16   COUNTFLAG  R    0     ������ϴζ�ȡ���Ĵ�����SysTick �Ѿ��Ƶ��� 0�����λΪ 1��
;                            �����ȡ��λ����λ���Զ�����
; 2    CLKSOURCE  R/W  0     0=�ⲿʱ��Դ(STCLK)
;                            1=�ں�ʱ��(FCLK)
; 1    TICKINT    R/W  0     1=SysTick����������0ʱ����SysTick�쳣����
;                            0=���� 0 ʱ�޶���
; 0    ENABLE     R/W  0     SysTick ��ʱ����ʹ��λ
SysTick_CTRL    EQU     0x00
; SysTick��װ����ֵ�Ĵ���
SysTick_LOAD    EQU     0x04
; SysTick��ǰ��ֵ�Ĵ���
SysTick_VAL     EQU     0x08
; SysTickУ׼��ֵ�Ĵ���
SysTick_CV      EQU     0x0C

; System Control Block Base Address  ϵͳ���ƿ��ַ
SCB_BASE        EQU     (SCS_BASE + 0x0D00)
; CPU ID�Ĵ���(ֻ��)
SCB_CPUID       EQU     0x00
; Interrupt Control and State Register  �жϿ��ƺ�״̬�Ĵ���
SCB_ICSR        EQU     0x04
; Vector Table Offset Register  �ж�������ƫ�����Ĵ���
SCB_VTOR        EQU     0x08
; Application Interrupt and Reset Control Register  Ӧ�ó����жϼ���λ���ƼĴ���
SCB_AIRCR       EQU     0x0C
; ϵͳ�쳣(�ж�)���ȼ��Ĵ�������
SCB_SHP         EQU     0x18
; System Handler Control and State Register ϵͳHandler���Ƽ�״̬�Ĵ���
SCB_SHCSR       EQU     0x24

NVIC_BASE       EQU     (SCS_BASE +  0x0100)

; ����洢���ӿ�
FLASH_BASE      EQU     0x40022000
FLASH_ACR       EQU     0x00
FLASH_KEYR      EQU     0x04
FLASH_OPTKEYR   EQU     0x08
FLASH_SR        EQU     0x0C
FLASH_CR        EQU     0x10
FLASH_AR        EQU     0x14
FLASH_OBR       EQU     0x1C
FLASH_WRPR      EQU     0x20

; RCC�Ĵ�������ַ
RCC_BASE        EQU     0x40021000
; ʱ�ӿ��ƼĴ���
RCC_CR          EQU     0x00
; ʱ�����üĴ���
RCC_CFGR        EQU     0x04
; ʱ���жϼĴ���
RCC_CIR         EQU     0x08
; APB2 ���踴λ�Ĵ���
RCC_APB2RSTR    EQU     0x0C
; APB1 ���踴λ�Ĵ���
RCC_APB1RSTR    EQU     0x10
; AHB����ʱ��ʹ�ܼĴ���
RCC_AHBENR      EQU     0x14
; APB2 ����ʱ��ʹ�ܼĴ���
RCC_APB2ENR     EQU     0x18
; APB1 ����ʱ��ʹ�ܼĴ���
RCC_APB1ENR     EQU     0x1C
; ��������ƼĴ���
RCC_BDCR        EQU     0x20
; ����/״̬�Ĵ���
RCC_CSR         EQU     0x24

; GPIOD�Ĵ�������ַ
GPIOD_BASE      EQU     0x40011400
; GPIOC�Ĵ�������ַ
GPIOC_BASE      EQU     0x40011000
; GPIOB�Ĵ�������ַ
GPIOB_BASE      EQU     0x40010C00
; GPIOA�Ĵ�������ַ
GPIOA_BASE      EQU     0x40010800

; �˿����õͼĴ���
GPIOx_CRL       EQU     0x00
; �˿����ø߼Ĵ���
GPIOx_CRH       EQU     0x04
GPIOx_IDR       EQU     0x08
GPIOx_ODR       EQU     0x0C
GPIOx_BSRR      EQU     0x10
GPIOx_BRR       EQU     0x14
; �˿����������Ĵ���
GPIOx_LCKR      EQU     0x18

; Usart1 ����1
USART1_BASE     EQU     0x40013800
; ״̬�Ĵ���
USART_SR        EQU     0x00
; ���ݼĴ���
USART_DR        EQU     0x04
; ���ر��ʼĴ���
USART_BRR       EQU     0x08
; ���ƼĴ��� 1
USART_CR1       EQU     0x0C
; ���ƼĴ��� 2
USART_CR2       EQU     0x10
; ���ƼĴ��� 3
USART_CR3       EQU     0x14
; ����ʱ���Ԥ��Ƶ�Ĵ���
USART_GTPR      EQU     0x18

; I2C1
I2C1_BASE       EQU     0x40005400
; I2C���ƼĴ��� 1
I2C_CR1         EQU     0x00
; I2C���ƼĴ��� 2
I2C_CR2         EQU     0x04
; �����ַ�Ĵ��� 1
I2C_OAR1        EQU     0x08
; �����ַ�Ĵ��� 2
I2C_OAR2        EQU     0x0C
; ���ݼĴ���
I2C_DR          EQU     0x10
; ״̬�Ĵ��� 1
I2C_SR1         EQU     0x14
; ״̬�Ĵ��� 2
I2C_SR2         EQU     0x18
; ʱ�ӿ��ƼĴ���
I2C_CCR         EQU     0x1C
; TRISE�Ĵ���
I2C_TRISE       EQU     0x20

I2C_EVENT_MASTER_MODE_SELECT\
                EQU     0x00030001
I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED\
                EQU     0x00070082
I2C_EVENT_MASTER_BYTE_TRANSMITTED\
                EQU     0x00070084

; ϵͳʱ�䣬��λ���룬8�ֽ�
SysTimeStamp    EQU     0x20000004

; �ж����ȼ���0��0Bit��ռ���ȼ� 4Bit�����ȼ�
NVIC_PRIORITYGROUP_0\
                EQU     0x0700
; �ж����ȼ���1��1Bit��ռ���ȼ� 3Bit�����ȼ�
NVIC_PRIORITYGROUP_1\
                EQU     0x0600
; �ж����ȼ���2��2Bit��ռ���ȼ� 2Bit�����ȼ�
NVIC_PRIORITYGROUP_2\
                EQU     0x0500
; �ж����ȼ���3��3Bit��ռ���ȼ� 1Bit�����ȼ�
NVIC_PRIORITYGROUP_3\
                EQU     0x0400
; �ж����ȼ���4��4Bit��ռ���ȼ� 0Bit�����ȼ�
NVIC_PRIORITYGROUP_4\
                EQU     0x0300

                END
