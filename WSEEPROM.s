//
//  WSEEPROM.s
//  Bandai WonderSwan EEPROM adapter emulation
//
//  Created by Fredrik Ahlström on 2021-11-10.
//  Copyright © 2021-2024 Fredrik Ahlström. All rights reserved.
//

#ifdef __arm__

#include "WSEEPROM.i"

	.global wsEepromReset
	.global wsEepromSetSize
	.global wsEepromWriteByte
	.global wsEepromSaveState
	.global wsEepromLoadState
	.global wsEepromGetStateSize

	.global wsEepromDataLowR
	.global wsEepromDataHighR
	.global wsEepromAddressLowR
	.global wsEepromAddressHighR
	.global wsEepromStatusR
	.global wsEepromDataLowW
	.global wsEepromDataHighW
	.global wsEepromAddressLowW
	.global wsEepromAddressHighW
	.global wsEepromCommandW


	.syntax unified
	.arm

#ifdef GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text						;@ For anything else
#endif
	.align 2
;@----------------------------------------------------------------------------
wsEepromReset:				;@ In r0 = eeptr, r1 = size(in bytes), r2 = *memory
							;@ r3 = allow protect (!= 0)
	.type wsEepromReset STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r0-r3,lr}

	ldr r1,=wsEepromSize/4
	bl memclr_					;@ Clear WSEeprom state

	ldmfd sp!,{r0-r3,lr}
	str r2,[eeptr,#eepMemory]
	strb r3,[eeptr,#eepProtect]
;@----------------------------------------------------------------------------
wsEepromSetSize:			;@ r0 = eeptr, r1 = size(in bytes)
	.type wsEepromSetSize STT_FUNC
;@----------------------------------------------------------------------------
	mov r3,#6					;@ 1kbit
	mov r2,#0x80
	cmp r1,#0x100				;@ 2kbit
	movpl r3,#8
	movpl r2,#0x100
	cmp r1,#0x200				;@ 4kbit
	movpl r2,#0x200
	cmp r1,#0x400				;@ 8kbit
	movpl r3,#10
	movpl r2,#0x400
	cmp r1,#0x800				;@ 16kbit
	movpl r2,#0x800
	strb r3,[eeptr,#eepAdrBits]
	str r2,[eeptr,#eepSize]
	sub r2,r2,#1
	str r2,[eeptr,#eepMask]

	bx lr
;@----------------------------------------------------------------------------
wsEepromWriteByte:			;@ r0 = eeptr, r1 = offset, r2 = value
;@----------------------------------------------------------------------------
	ldr r3,[eeptr,#eepMask]
	and r1,r3,r1
	ldr r3,[eeptr,#eepMemory]
	strb r2,[r3,r1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromSaveState:			;@ In r0=destination, r1=eeptr. Out r0=state size.
	.type wsEepromSaveState STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4,r5,lr}
	mov r4,r0					;@ Store destination
	mov r5,r1					;@ Store eeptr (r1)

	add r1,r5,#wsEepromState
	mov r2,#(wsEepromStateEnd-wsEepromState)
	bl memcpy

	add r0,r4,#(wsEepromStateEnd-wsEepromState)
	ldr r1,[r5,#eepMemory]
	ldr r2,[r5,#eepSize]
	bl memcpy

	ldmfd sp!,{r4,r5,lr}
	ldr r0,=(wsEepromStateEnd-wsEepromState)+0x800
	bx lr
;@----------------------------------------------------------------------------
wsEepromLoadState:			;@ In r0=eeptr, r1=source. Out r0=state size.
	.type wsEepromLoadState STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4,r5,lr}
	mov r5,r0					;@ Store eeptr (r0)
	mov r4,r1					;@ Store source

	add r0,r5,#wsEepromState
	mov r2,#(wsEepromStateEnd-wsEepromState)
	bl memcpy

	ldr r0,[r5,#eepMemory]
	add r1,r4,#(wsEepromStateEnd-wsEepromState)
	ldr r2,[r5,#eepSize]
	bl memcpy

	ldmfd sp!,{r4,r5,lr}
;@----------------------------------------------------------------------------
wsEepromGetStateSize:		;@ Out r0=state size.
	.type wsEepromGetStateSize STT_FUNC
;@----------------------------------------------------------------------------
	ldr r0,=(wsEepromStateEnd-wsEepromState)+0x800
	bx lr

	.pool
;@----------------------------------------------------------------------------
wsEepromDataLowR:			;@ r0=eeptr
	.type wsEepromDataLowR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepDataIn]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDataHighR:			;@ r0=eeptr
	.type wsEepromDataHighR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepDataIn+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressLowR:		;@ r0=eeptr
	.type wsEepromAddressLowR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepAddress]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressHighR:		;@ r0=eeptr
	.type wsEepromAddressHighR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepAddress+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromStatusR:			;@ r0=eeptr
	.type wsEepromStatusR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r2,[eeptr,#eepStatus]
	ldrb r1,[eeptr,#eepCommand]
	mov r3,r2
	cmp r1,#0x10				;@ Read
	orreq r3,r3,#1				;@ Read done
	cmp r1,#0x20				;@ Write
	cmpne r1,#0x40				;@ Erase
	orreq r3,r3,#2				;@ W/E done
	strb r3,[eeptr,#eepStatus]
	mov r0,r2
	bx lr
// bit(0) = read ready;
// bit(1) = Idle;
// bit(7) = protect enabled;
;@----------------------------------------------------------------------------
wsEepromDataLowW:			;@ , r0=eeptr, r1 = value
	.type wsEepromDataLowW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepDataOut]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDataHighW:			;@ r0=eeptr, r1 = value
	.type wsEepromDataHighW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepDataOut+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressLowW:		;@ r0=eeptr, r1 = value
	.type wsEepromAddressLowW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepAddress]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressHighW:		;@ r0=eeptr, r1 = value
	.type wsEepromAddressHighW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepAddress+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromCommandW:			;@ r0=eeptr, r1 = value
	.type wsEepromCommandW STT_FUNC
;@----------------------------------------------------------------------------
	and r1,r1,#0xF0
	strb r1,[eeptr,#eepCommand]

	cmp r1,#0x10				;@ Read
	beq wsEepromDoRead
	cmp r1,#0x20				;@ Write
	beq wsEepromDoWrite
	cmp r1,#0x40				;@ Erase/Short op
	beq wsEepromDoErase
	cmp r1,#0x80				;@ Write protect (only internal EEPROM)
	beq wsEepromDoProtect
	bx lr						;@ Only 1 bit can be set
;@----------------------------------------------------------------------------
wsEepromDoRead:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepAdrBits]
	ldr r2,[eeptr,#eepAddress]
	mov r3,r2,lsr r1
	cmp r3,#0x6					;@ Read?
	bxne lr
	ldr r3,[eeptr,#eepMask]
	and r2,r3,r2,lsl#1
	ldr r3,[eeptr,#eepMemory]
	ldrh r1,[r3,r2]
	strh r1,[eeptr,#eepDataIn]
	ldrb r1,[eeptr,#eepStatus]
	bic r1,r1,#1
	strb r1,[eeptr,#eepStatus]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDoWrite:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepAdrBits]
	ldr r2,[eeptr,#eepAddress]
	mov r3,r2,lsr r1
	cmp r3,#0x4					;@ Sub Command?
	beq wsEprSubCmd
	cmp r3,#0x5					;@ Write?
	bxne lr
	bic r2,r2,r3,lsl r1
	ldrb r1,[eeptr,#eepWDS]		;@ Write disabled?
	cmp r1,#0
	bxne lr
	ldrb r1,[eeptr,#eepStatus]
	tst r1,r1,lsr#8				;@ Write protect over 0x30?
	cmpcs r2,#0x30
	bxcs lr
	bic r1,r1,#2
	strb r1,[eeptr,#eepStatus]
	ldr r3,[eeptr,#eepMask]
	and r2,r3,r2,lsl#1
	ldr r3,[eeptr,#eepMemory]
	ldrh r1,[eeptr,#eepDataOut]
	strh r1,[r3,r2]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDoErase:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepAdrBits]
	ldr r2,[eeptr,#eepAddress]
	mov r3,r2,lsr r1
	cmp r3,#0x4					;@ Sub Command?
	beq wsEprSubCmd
	cmp r3,#0x7					;@ Erase?
	bxne lr
	bic r2,r2,r3,lsl r1
	ldrb r1,[eeptr,#eepWDS]		;@ Write disabled?
	cmp r1,#0
	bxne lr
	ldrb r1,[eeptr,#eepStatus]
	tst r1,r1,lsr#8				;@ Write protect over 0x30?
	cmpcs r2,#0x30
	bxcs lr
	bic r1,r1,#2
	strb r1,[eeptr,#eepStatus]
	ldr r3,[eeptr,#eepMask]
	and r2,r3,r2,lsl#1
	ldr r3,[eeptr,#eepMemory]
	mov r1,#-1
	strh r1,[r3,r2]
	bx lr

wsEprSubCmd:
	sub r1,r1,#2
	mov r3,r2,lsr r1			;@ Sub command
	ands r3,r3,#0xF				;@ 0=WDS
	eor r1,r3,#3
	cmpne r3,#0x3				;@ WEN?
	strbeq r1,[eeptr,#eepWDS]
	bxeq lr
	cmp r3,#0x2					;@ WRAL?
	mov r1,#-1
	ldrheq r1,[eeptr,#eepDataOut]
	cmpne r3,#0x1					;@ ERAL?
	bxne lr

	ldr r2,[eeptr,#eepMask]
	ldr r3,[eeptr,#eepMemory]
allLoop:
	strh r1,[r3,r2]
	subs r2,r2,#1
	bpl allLoop
	bx lr
;@----------------------------------------------------------------------------
wsEepromDoProtect:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepProtect]
	cmp r1,#0
	ldrb r1,[eeptr,#eepStatus]
	orrne r1,r1,#0x80
	strb r1,[eeptr,#eepStatus]
	bx lr

#endif // #ifdef __arm__
