//
//  WSEEPROM.i
//  WSEEPROM
//
//  Created by Fredrik Ahlström on 2021-11-10.
//  Copyright © 2021-2023 Fredrik Ahlström. All rights reserved.
//
// ASM header for the Bandai WonderSwan EEPROM emulator

	eeptr		.req r0
						;@ WSEEPROM.s
	.struct 0
eepMemory:		.long 0
wsEepromState:
eepSize:		.long 0		;@ Size in bytes
eepMask:		.long 0		;@ Address mask (size - 1)
eepAddress:		.long 0		;@ Current address
eepData:		.short 0	;@ Current data
eepStatus:		.byte 0		;@ Status value
eepAdrBits:		.byte 0		;@ Number of bits in the address
eepMode:		.byte 0		;@
eepCommand:		.byte 0		;@
eepProtect:		.byte 0		;@ Protect possible
eepPadding1:	.space 1	;@
wsEepromStateEnd:

wsEepromSize:

;@----------------------------------------------------------------------------

