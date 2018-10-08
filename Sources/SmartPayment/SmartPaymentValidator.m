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

#import "SmartPaymentValidator.h"
#import "IBANValidator.h"
#import "SmartPaymentAccount.h"

@interface SmartPaymentValidator ()
{
	SmartPaymentConfiguration * _configuration;

	NSNumberFormatter * _decimalFormatter;
	NSNumberFormatter * _integerFormatter;
	NSDateFormatter * _dateFormatter;
	IBANValidator * _ibanValidator;
	NSMutableArray * _errors;
	NSLocale * _usLocale;

	NSCharacterSet * _numbersValidator;
	NSCharacterSet * _amountValidator;
}

@end

@implementation SmartPaymentValidator

- (id) initWithConfiguration:(SmartPaymentConfiguration*)configuration
{
	self = [super init];
	if (self) {
		_configuration = configuration;

		_decimalFormatter = [[NSNumberFormatter alloc] init];
		_decimalFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		_decimalFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
		_decimalFormatter.alwaysShowsDecimalSeparator = NO;
		_decimalFormatter.groupingSeparator = @"";
		_decimalFormatter.minimumFractionDigits = 2;
		_decimalFormatter.maximumFractionDigits = 2;

		_integerFormatter = [[NSNumberFormatter alloc] init];
		_integerFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
		_integerFormatter.allowsFloats = NO;

		_dateFormatter = [[NSDateFormatter alloc] init];
		_dateFormatter.dateFormat = @"yyyyMMdd";
		_dateFormatter.timeZone = _configuration.timeZone;

		_ibanValidator = [[IBANValidator alloc] init];

		_usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];

		_numbersValidator = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
		_amountValidator = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
	}
	return self;
}

- (NSArray*) errors
{
	return _errors;
}

- (NSError*) firstError
{
	if (_errors.count > 0) {
		return [_errors objectAtIndex:0];
	}
	return nil;
}

- (NSDictionary*) validateInputValues:(NSDictionary *)values withDefinition:(NSDictionary *)definition
{
	NSMutableDictionary * translatedValues = [NSMutableDictionary dictionaryWithCapacity:values.count];
	_errors = [NSMutableArray array];

	[values enumerateKeysAndObjectsUsingBlock:^(NSString * tag, NSString * value, BOOL *stop) {

		NSArray * entry = [definition objectForKey:tag];

		if ([tag isEqualToString:kSmartPaymentKey_Header]) {
			[translatedValues setObject:value forKey:tag];
			return;
		}

		if (entry) {
			SmartPaymentValueType valueType = [[entry objectAtIndex:0] intValue];
			NSArray * params = entry.count > 1 ? [entry objectAtIndex:1] : nil;

			id result = nil;
			NSString * error = nil;

			switch (valueType)
			{
				case SmartPaymentValueType_Amount:
					result = [self validateAmount:value error:&error];
					break;

				case SmartPaymentValueType_IBAN:
					result = [self validateIBAN:value error:&error];
					break;

				case SmartPaymentValueType_Number:
					result = [self validateNumber:value params:params error:&error];
					break;

				case SmartPaymentValueType_String:
					result = [self validateString:value params:params error:&error];
					break;

				case SmartPaymentValueType_NumberStr:
					result = [self validateNumberStr:value params:params error:&error];
					break;

				case SmartPaymentValueType_Enum:
					result = [self validateEnum:value params:params error:&error];
					break;

				case SmartPaymentValueType_Date:
					result = [self validateDate:value params:params error:&error];
					break;

				case SmartPaymentValueType_RegExp:
					result = [self validateRegexp:value params:params error:&error];
					break;

				case SmartPaymentValueType_IBANs:
				{
					NSArray * accountComponents = [value componentsSeparatedByString:@","];
					NSMutableArray * accounts = [NSMutableArray arrayWithCapacity:accountComponents.count];
					for (NSString * iban in accountComponents) {
						SmartPaymentAccount * account = [self validateIBAN:iban error:&error];
						if (account) {
							[accounts addObject:account];
						} else {
							accounts = nil;
							break;
						}
					}
					if (accounts.count > 0) {
						result = accounts;
					}
					break;
				}

				case SmartPaymentValueType_Frequency:
					result = [self validateFrequency:value error:&error];
					break;

				case SmartPaymentValueType_Boolean:
					result = [self validateBoolean:value error:&error];
					break;

				default:
					NSLog(@"SmartPaymentValidator: Unsupported value type %d", valueType);
					break;
			}

			if (!result) {
				// make an error
				NSString * errorString = nil;
				if (error) {
					errorString = [NSString stringWithFormat:@"Value in %@ is not valid: %@", tag, error];
				} else {
					errorString = [NSString stringWithFormat:@"Value in %@ is not valid.", tag];
				}
				[_errors addObject:[NSError errorWithDomain:kSmartPaymentErrorDomain
													   code:SmartPaymentError_DataError
												   userInfo:[NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey]
									]
				 ];
			} else {
				[translatedValues setObject:result forKey:tag];
			}

		} else {
			NSLog(@"SmartPaymentValidator: WARNING: There's missing definition for tag '%@'", tag);
		}
	}];

	if (_errors.count > 0) {
		return nil;
	}

	return translatedValues;
}


#pragma mark - Validation methods

- (NSDecimalNumber*) validateAmount:(NSString*)value error:(NSString**)error
{
	NSRange range = [value rangeOfCharacterFromSet:_amountValidator];
	if (range.length > 0) {
		return nil;
	}
	return [[NSDecimalNumber alloc] initWithString:value locale:_usLocale];
}

- (SmartPaymentAccount*) validateIBAN:(NSString*)value error:(NSString**)error
{
	Class accountClass = _configuration.classForSmartPaymentAccount;
	if (!accountClass) {
		accountClass = [SmartPaymentAccount class];
	}
	SmartPaymentAccount * account = [[accountClass alloc] initWithString:value];
	IBANValidationResult result = [_ibanValidator validateElectronicIBAN:account.iban];
	if (result != IBANValidation_OK) {
		return nil;
	}
	return account;
}

- (NSNumber*) validateNumber:(NSString*)value params:(NSArray*)params error:(NSString**)error
{
	NSRange range = [value rangeOfCharacterFromSet:_numbersValidator];
	if (range.length > 0) {
		return nil;
	}
	NSNumber * number = [_integerFormatter numberFromString:value];
	if (params && number) {
		NSInteger min = [[params objectAtIndex:0] unsignedIntegerValue];
		NSInteger max = [[params objectAtIndex:1] unsignedIntegerValue];
		NSInteger num = [number integerValue];
		if (num < min || num > max) {
			return nil;
		}
	}
	return number;
}

- (NSString*) validateString:(NSString*)value params:(NSArray*)params error:(NSString**)error
{
	if (params) {
		NSUInteger min = [[params objectAtIndex:0] unsignedIntegerValue];
		NSUInteger max = [[params objectAtIndex:1] unsignedIntegerValue];
		NSUInteger length = value.length;
		if (length < min) {
			return nil;
		}
		if (length > max) {
			if (params.count > 2) {
				BOOL canCropValue = [[params objectAtIndex:2] boolValue];
				if (canCropValue) {
					value = [value substringToIndex:max];
				} else {
					return nil;
				}
			} else {
				return nil;
			}
		}
	}
	return value;
}

- (NSString*) validateNumberStr:(NSString*)value params:(NSArray*)params error:(NSString**)error
{
	NSRange range = [value rangeOfCharacterFromSet:_numbersValidator];
	if (range.length > 0) {
		return nil;
	}
	if (params) {
		NSUInteger min = [[params objectAtIndex:0] unsignedIntegerValue];
		NSUInteger max = [[params objectAtIndex:1] unsignedIntegerValue];
		NSUInteger length = value.length;
		if (length < min) {
			return nil;
		}
		if (length > max) {
			if (params.count > 2) {
				BOOL canCropValue = [[params objectAtIndex:2] boolValue];
				if (canCropValue) {
					value = [value substringToIndex:max];
				} else {
					return nil;
				}
			} else {
				return nil;
			}
		}
	}
	return value;
}

- (NSString*) validateRegexp:(NSString*)value params:(NSArray*)params error:(NSString**)error
{
	NSAssert(NO, @"validateRegexp is not implemented yet");
	return nil;
}

- (NSNumber*) validateEnum:(NSString*)value params:(NSArray*)params error:(NSString**)error
{
	if (!params) {
		return nil;
	}
	NSUInteger index = [params indexOfObject:value];
	if (index == NSNotFound) {
		return nil;
	}
	return [NSNumber numberWithInt:(int)index + 1];
}

- (NSDate*) validateDate:(NSString*)value params:(NSArray*)params error:(NSString**)error
{
	NSRange range = [value rangeOfCharacterFromSet:_numbersValidator];
	if (range.length > 0) {
		return nil;
	}
	return [_dateFormatter dateFromString:value];
}

- (NSString *)validateFrequency:(NSString *)rawString error:(NSString **)error {

	NSString *uppercasedString = [rawString uppercaseString];
	NSArray *validFrequencies = @[
								  @"1D",
								  @"1M",
								  @"3M",
								  @"6M",
								  @"1Y"
								  ];
	if ([validFrequencies containsObject:uppercasedString]) {
		return uppercasedString;
	} else {
		return nil;
	}
}

- (NSNumber *)validateBoolean:(NSString *)rawValue error:(NSString **)error {
	return [rawValue integerValue] == 0 ? @(0) : @(1);
}

@end
