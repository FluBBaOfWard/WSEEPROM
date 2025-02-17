//
//  WSEEPROM.i
//  Bandai WonderSwan EEPROM adapter emulation
//
//  Created by Fredrik Ahlström on 2021-11-10.
//  Copyright © 2021-2025 Fredrik Ahlström. All rights reserved.
//

#if !__ASSEMBLER__
	#error This header file is only for use in assembly files!
#endif

	eeptr		.req r0
						;@ WSEEPROM.s
	.struct 0
eepMemory:		.long 0
wsEepromState:
eepSize:		.long 0		;@ Size in bytes
eepMask:		.long 0		;@ Address mask (size - 1)
eepAddress:		.long 0		;@ Current address
eepDataIn:		.short 0	;@ Current in data
eepDataOut:		.short 0	;@ Current out data
eepStatus:		.byte 0		;@ Status value
eepAdrBits:		.byte 0		;@ Number of bits in the address
eepWDS:			.byte 0		;@ Write disabled
eepCommand:		.byte 0		;@
eepProtect:		.byte 0		;@ Protect possible
eepStatCmd0:	.byte 0		;@ Bits cleared with command (except read)
eepStatRead0:	.byte 0		;@ Bits cleared with read
eepPadding1:	.space 1	;@
wsEepromStateEnd:

wsEepromSize:
	.previous

;@----------------------------------------------------------------------------

