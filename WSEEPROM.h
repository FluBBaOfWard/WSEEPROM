//
//  WSEEPROM.h
//  Bandai WonderSwan EEPROM adapter emulation
//
//  Created by Fredrik Ahlström on 2021-11-10.
//  Copyright © 2021-2024 Fredrik Ahlström. All rights reserved.
//
// CSI 93C86S
// Seiko S-29530
// STMicroElectronic M93Cx6
// https://www.st.com/resource/en/datasheet/m93c46-w.pdf
// Microchip 93LCx6
//  93LC06 =>   256 cells =>   32 x 8-bit or   16 x 16-bit
//  93LC46 =>  1024 cells =>  128 x 8-bit or   64 x 16-bit
//  93LC56 =>  2048 cells =>  256 x 8-bit or  128 x 16-bit
//  93LC66 =>  4096 cells =>  512 x 8-bit or  256 x 16-bit
//  93LC76 =>  8192 cells => 1024 x 8-bit or  512 x 16-bit
//  93LC86 => 16384 cells => 2048 x 8-bit or 1024 x 16-bit

#ifndef WSEEPROM_HEADER
#define WSEEPROM_HEADER

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	void *memory;
	/** Size in bytes */
	int size;
	/** Address mask (size - 1) */
	int mask;
	/** Current address */
	int address;
	/** Current in data value */
	short dataIn;
	/** Current out data value */
	short dataOut;
	/** Status value */
	u8 status;
	/** Number of bits in the address */
	u8 adrBits;
	/** Write disabled */
	u8 WDS;
	u8 command;
	/** Protect possible */
	u8 protect;
	u8 padding1[3];
} WSEEPROM;

void wsEepromReset(WSEEPROM *chip, int size, void *mem, bool allowProtect);
void wsEepromSetSize(WSEEPROM *chip, int size);
void wsEepromWriteByte(WSEEPROM *chip, int offset, int value);

/**
 * Saves the state of the chip to the destination.
 * @param  *destination: Where to save the state.
 * @param  *chip: The WSEEPROM chip to save.
 * @return The size of the state.
 */
int wsEepromSaveState(void *destination, const WSEEPROM *chip);

/**
 * Loads the state of the chip from the source.
 * @param  *chip: The WSEEPROM chip to load a state into.
 * @param  *source: Where to load the state from.
 * @return The size of the state.
 */
int wsEepromLoadState(WSEEPROM *chip, const void *source);

/**
 * Gets the state size of a WSEEPROM chip.
 * @return The size of the state.
 */
int wsEepromGetStateSize(void);

int wsEepromDataLowR(WSEEPROM *chip);
int wsEepromDataHighR(WSEEPROM *chip);
int wsEepromAddressLowR(WSEEPROM *chip);
int wsEepromAddressHighR(WSEEPROM *chip);
int wsEepromStatusR(WSEEPROM *chip);
void wsEepromDataLowW(WSEEPROM *chip, int value);
void wsEepromDataHighW(WSEEPROM *chip, int value);
void wsEepromAddressLowW(WSEEPROM *chip, int value);
void wsEepromAddressHighW(WSEEPROM *chip, int value);
void wsEepromCommandW(WSEEPROM *chip, int value);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // WSEEPROM_HEADER
