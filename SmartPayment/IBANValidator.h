/*
 * [/] SmartPlatba
 *
 * Copyright 2012 www.qr-platba.cz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Juraj Durech <juraj@inmite.eu>
 */

#import <Foundation/Foundation.h>

typedef enum {
	IBANValidation_OK,					// IBAN is valid
	IBANValidation_UnknownCountry,		// IBAN is valid, but country is unknown. You may ignore this error.
	IBANValidation_Error,				// IBAN is invalid
} IBANValidationResult;


@interface IBANValidator : NSObject

// Validates IBAN in normalized electronic format (e.g. without spaces, uppercase characters)
- (IBANValidationResult) validateElectronicIBAN:(NSString*)iban;

// Validates IBAN in more vague form (may contain spaces)
- (IBANValidationResult) validateIBAN:(NSString*)iban;

// Various helpers

// Validates string agains Mod97_10 test
+ (IBANValidationResult) validateMod97:(NSString*)string;

@end
