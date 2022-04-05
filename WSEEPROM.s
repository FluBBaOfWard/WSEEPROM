// Bandai WonderSwan EEPROM emulation

#ifdef __arm__
//
//  WSEEPROM.s
//  WSEEPROM
//
//  Created by Fredrik Ahlström on 2021-11-10.
//  Copyright © 2021-2022 Fredrik Ahlström. All rights reserved.
//

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

#if GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text						;@ For anything else
#endif
	.align 2
;@----------------------------------------------------------------------------
wsEepromReset:			;@ In r0 = eeptr, r1 = size(in bytes), r2 = *memory
	.type   wsEepromReset STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r0-r2,lr}

	ldr r1,=wsEepromSize/4
	bl memclr_					;@ Clear WSEeprom state

	ldmfd sp!,{r0-r2,lr}
	str r2,[eeptr,#eepMemory]
;@----------------------------------------------------------------------------
wsEepromSetSize:		;@ r0 = eeptr, r1 = size(in bytes)
	.type   wsEepromSetSize STT_FUNC
;@----------------------------------------------------------------------------
	mov r2,#0x80				;@ 1kbit
	mov r3,#6
	cmp r1,#0x100				;@ 2kbit
	movpl r2,#0x100
	movpl r3,#7
	cmp r1,#0x200				;@ 4kbit
	movpl r2,#0x200
	movpl r3,#8
	cmp r1,#0x400				;@ 8kbit
	movpl r2,#0x400
	movpl r3,#9
	cmp r1,#0x800				;@ 16kbit
	movpl r2,#0x800
	movpl r3,#10
	str r2,[eeptr,#eepSize]
	sub r2,r2,#1
	str r2,[eeptr,#eepMask]
	strb r3,[eeptr,#eepAdrBits]

	bx lr
;@----------------------------------------------------------------------------
wsEepromWriteByte:		;@ r0 = eeptr, r1 = offset, r2 = value
;@----------------------------------------------------------------------------
	ldr r3,[eeptr,#eepMask]
	and r1,r3,r1
	ldr r3,[eeptr,#eepMemory]
	strb r2,[r3,r1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromSaveState:		;@ In r0=destination, r1=eeptr. Out r0=state size.
	.type   wsEepromSaveState STT_FUNC
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
wsEepromLoadState:		;@ In r0=eeptr, r1=source. Out r0=state size.
	.type   wsEepromLoadState STT_FUNC
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
wsEepromGetStateSize:	;@ Out r0=state size.
	.type   wsEepromGetStateSize STT_FUNC
;@----------------------------------------------------------------------------
	ldr r0,=(wsEepromStateEnd-wsEepromState)+0x800
	bx lr

	.pool
;@----------------------------------------------------------------------------
wsEepromDataLowR:		;@ r0=eeptr
	.type   wsEepromDataLowR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepData]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDataHighR:		;@ r0=eeptr
	.type   wsEepromDataHighR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepData+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressLowR:	;@ r0=eeptr
	.type   wsEepromAddressLowR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepAddress]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressHighR:	;@ r0=eeptr
	.type   wsEepromAddressHighR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepAddress+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromStatusR:	;@ r0=eeptr
	.type   wsEepromStatusR STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,[eeptr,#eepStatus]
	bx lr
// bit(0) = readReady;
// bit(1) = writeReady;
// bit(2) = eraseReady;
// bit(3) = resetReady;
// bit(4) = readPending;
// bit(5) = writePending;
// bit(6) = erasePending;
// bit(7) = resetPending;
;@----------------------------------------------------------------------------
wsEepromDataLowW:		;@ , r0=eeptr, r1 = value
	.type   wsEepromDataLowW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepData]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDataHighW:		;@ r0=eeptr, r1 = value
	.type   wsEepromDataHighW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepData+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressLowW:	;@ r0=eeptr, r1 = value
	.type   wsEepromAddressLowW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepAddress]
	bx lr
;@----------------------------------------------------------------------------
wsEepromAddressHighW:	;@ r0=eeptr, r1 = value
	.type   wsEepromAddressHighW STT_FUNC
;@----------------------------------------------------------------------------
	strb r1,[eeptr,#eepAddress+1]
	bx lr
;@----------------------------------------------------------------------------
wsEepromCommandW:		;@ r0=eeptr, r1 = value
	.type   wsEepromCommandW STT_FUNC
;@----------------------------------------------------------------------------
	and r1,r1,#0xF0
	strb r1,[eeptr,#eepCommand]

	cmp r1,#0x10	;@ Read
	beq wsEepromDoRead
	cmp r1,#0x20	;@ Write
	beq wsEepromDoWrite
	cmp r1,#0x40	;@ Erase
	beq wsEepromDoErase
	cmp r1,#0x80	;@ Reset
	beq wsEepromDoReset
	bx lr			;@ Only 1 bit can be set
;@----------------------------------------------------------------------------
wsEepromDoRead:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepAdrBits]
	ldr r2,[eeptr,#eepAddress]
	mov r3,r2,lsr r1
	and r3,r3,#0x7
	cmp r3,#0x6
	bxne lr
	ldr r3,[eeptr,#eepMask]
	and r2,r3,r2,lsl#1
	ldr r3,[eeptr,#eepMemory]
	ldrh r1,[r3,r2]
	strh r1,[eeptr,#eepData]
	mov r1,#1
	strb r1,[eeptr,#eepStatus]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDoWrite:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepAdrBits]
	ldr r2,[eeptr,#eepAddress]
	mov r3,r2,lsr r1
	and r3,r3,#0x7
	cmp r3,#0x5
	bxne lr
	ldr r3,[eeptr,#eepMask]
	and r2,r3,r2,lsl#1
	ldr r3,[eeptr,#eepMemory]
	ldrh r1,[eeptr,#eepData]
	strh r1,[r3,r2]
	mov r1,#2
	strb r1,[eeptr,#eepStatus]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDoErase:
;@----------------------------------------------------------------------------
	ldrb r1,[eeptr,#eepAdrBits]
	ldr r2,[eeptr,#eepAddress]
	mov r3,r2,lsr r1
	and r3,r3,#0x7
	cmp r3,#0x7				;@ Erase?
	bxne lr
	ldr r3,[eeptr,#eepMask]
	and r2,r3,r2,lsl#1
	ldr r3,[eeptr,#eepMemory]
	mov r1,#-1
	strh r1,[r3,r2]
	mov r1,#4
	strb r1,[eeptr,#eepStatus]
	bx lr
;@----------------------------------------------------------------------------
wsEepromDoReset:
;@----------------------------------------------------------------------------
	mov r11,r11
	mov r1,#8
	strb r1,[eeptr,#eepStatus]
	bx lr

#endif // #ifdef __arm__
