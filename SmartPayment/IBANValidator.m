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

#import "IBANValidator.h"
#import "SmartPaymentUtils.h"

@interface IBANValidator()
{
	NSDictionary * _countryTable;
	NSCharacterSet * _validationSet;
}

- (NSDictionary*) buildCountryTable;
- (NSCharacterSet*) buildValidationCharSet;

@end

@implementation IBANValidator

#define IBAN_DEF(country, length)	[NSNumber numberWithInt:length], country
#define IBAN_DEF_LENGTH(def)		[def unsignedIntegerValue]


#pragma mark - Public Methods

- (id) init
{
	self = [super init];
	if (self) {
		_validationSet = [self buildValidationCharSet];
		_countryTable  = [self buildCountryTable];
	}
	return self;
}

- (IBANValidationResult) validateElectronicIBAN:(NSString*)iban
{
	NSUInteger ibanLength = [iban length];
	if (ibanLength < 15) {
		NSLog(@"IBANValidator: IBAN is too short or empty.");
		return IBANValidation_Error;
	}
	
	NSRange invalidCharacter = [iban rangeOfCharacterFromSet:_validationSet];
	if (invalidCharacter.length > 0) {
		NSLog(@"IBANValidator: IBAN contains invalid characters.");
		return IBANValidation_Error;
	}
	
	NSString * countryCode = [iban substringWithRange:NSMakeRange(0, 2)];
	id countryDescriptor = [_countryTable objectForKey:countryCode];
	BOOL countryIsValid = countryDescriptor != nil;
	if (countryIsValid) {
		NSUInteger expectedIbanLength = IBAN_DEF_LENGTH(countryDescriptor);
		if (expectedIbanLength != ibanLength) {
			NSLog(@"IBANValidator: IBAN doesn't fit to length requirements for country %@", countryCode);
			return IBANValidation_Error;
		}
	} else {
		NSLog(@"IBANValidator: Unsupported country %@", countryCode);
	}

	NSString * normalizedString = [NSString stringWithFormat:@"%@%@",
								   [iban substringFromIndex:4],
								   [iban substringToIndex:4]
								   ];
	IBANValidationResult result = [IBANValidator validateMod97:normalizedString];
	if (!countryIsValid && (result == IBANValidation_OK)) {
		// IBAN is valid but country is not in table.
		result = IBANValidation_UnknownCountry;
	}
	return result;
}


- (IBANValidationResult) validateIBAN:(NSString*)iban
{
	// TODO: add other freaky string cleanups...
	iban = [iban stringByReplacingOccurrencesOfString:@" " withString:@""];
	return [self validateElectronicIBAN:iban];
}


+ (IBANValidationResult) validateMod97:(NSString *)string
{
	NSUInteger checkSum = [SmartPaymentUtils calculateMod97:string];
	if (checkSum == 1) {
		return IBANValidation_OK;
	}
	return IBANValidation_Error;
}


#pragma mark - Inernal tables

- (NSCharacterSet*) buildValidationCharSet
{
	return [[NSCharacterSet characterSetWithCharactersInString:@"01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
}

- (NSDictionary*) buildCountryTable
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			IBAN_DEF(@"AL", 28),	// Albania
			IBAN_DEF(@"AD", 24),	// Andorra
			IBAN_DEF(@"AT", 20),	// Austria
			IBAN_DEF(@"AZ", 28),	// Azerbaijan
			IBAN_DEF(@"BE", 16),	// Belgium
			IBAN_DEF(@"BH", 22),	// Bahrain
			IBAN_DEF(@"BA", 20),	// Bosnia and Herzegovina
			IBAN_DEF(@"BG", 22),	// Bulgaria
			IBAN_DEF(@"CR", 21),	// Costa Rica
			
			IBAN_DEF(@"HR", 21),	// Croatia
			IBAN_DEF(@"CY", 28),	// Cyprus
			IBAN_DEF(@"CZ", 24),	// Czech Republic
			IBAN_DEF(@"DK", 18),	// Denmark
			IBAN_DEF(@"DO", 28),	// Dominican Republic
			IBAN_DEF(@"EE", 20),	// Estonia
			IBAN_DEF(@"FO", 18),	// Faroe Islands
			IBAN_DEF(@"FI", 18),	// Finland
			IBAN_DEF(@"FR", 27),	// France
			
			IBAN_DEF(@"GE", 22),	// Georgia
			IBAN_DEF(@"DE", 22),	// Germany
			IBAN_DEF(@"GI", 23),	// Gibraltar
			IBAN_DEF(@"GR", 27),	// Greece
			IBAN_DEF(@"GL", 18),	// Greenland
			IBAN_DEF(@"GT", 28),	// Guatemala
			IBAN_DEF(@"HU", 28),	// Hungary
			IBAN_DEF(@"IS", 26),	// Iceland
			IBAN_DEF(@"IE", 22),	// Ireland
			
			IBAN_DEF(@"IL", 23),	// Israel
			IBAN_DEF(@"IT", 27),	// Italy
			IBAN_DEF(@"KZ", 20),	// Kazakhstan
			IBAN_DEF(@"KW", 30),	// Kuwait
			IBAN_DEF(@"LV", 21),	// Latvia
			IBAN_DEF(@"LB", 28),	// Lebanon
			IBAN_DEF(@"LI", 21),	// Liechtenstein
			IBAN_DEF(@"LT", 20),	// Lituania
			IBAN_DEF(@"LU", 20),	// Luxembourg
			
			IBAN_DEF(@"MK", 19),	// Macedonia
			IBAN_DEF(@"MT", 31),	// Malta
			IBAN_DEF(@"MR", 27),	// Mauritania
			IBAN_DEF(@"MU", 30),	// Mauritius
			IBAN_DEF(@"MC", 27),	// Monaco
			IBAN_DEF(@"MD", 24),	// Moldova
			IBAN_DEF(@"ME", 22),	// Montenegro
			IBAN_DEF(@"NL", 18),	// Netherlands
			IBAN_DEF(@"NO", 15),	// Norway
			
			IBAN_DEF(@"PK", 24),	// Pakistan
			IBAN_DEF(@"PS", 29),	// Palestinian Territory
			IBAN_DEF(@"PL", 28),	// Poland
			IBAN_DEF(@"PT", 25),	// Portugal
			IBAN_DEF(@"RO", 24),	// Romania
			IBAN_DEF(@"SM", 27),	// San Marino
			IBAN_DEF(@"SA", 24),	// Saudi Arabia
			IBAN_DEF(@"RS", 22),	// Serbia
			IBAN_DEF(@"SK", 24),	// Little-Big Slovakia
			
			IBAN_DEF(@"SI", 19),	// Slovenia
			IBAN_DEF(@"ES", 24),	// Spain
			IBAN_DEF(@"SE", 24),	// Sweden
			IBAN_DEF(@"CH", 21),	// Switzerland
			IBAN_DEF(@"TN", 24),	// Tunisia
			IBAN_DEF(@"TR", 26),	// Turkey
			IBAN_DEF(@"AE", 23),	// United Arab Emirates
			IBAN_DEF(@"GB", 22),	// United Kingdom
			IBAN_DEF(@"VG", 24),	// Virgin Islands, British
			
			// TODO: check following setup
			
			IBAN_DEF(@"AO", 25),	// Angola
			IBAN_DEF(@"BI", 16),	// Burundi
			IBAN_DEF(@"CM", 27),	// Cameroon
			IBAN_DEF(@"CV", 25),	// Cape Verde
			IBAN_DEF(@"IR", 26),	// Iran
			IBAN_DEF(@"CI", 28),	// Ivory Coast
			IBAN_DEF(@"MG", 27),	// Madagascar
			IBAN_DEF(@"ML", 28),	// Mali
			IBAN_DEF(@"MZ", 25),	// Mozambique
			
			nil];
}


@end
