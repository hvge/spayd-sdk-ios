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

#import "SmartPaymentCZ.h"
#import "SmartPaymentUtils.h"

static NSString * const kX_VS  = @"X-VS";
static NSString * const kX_KS  = @"X-KS";
static NSString * const kX_SS  = @"X-SS";
static NSString * const kX_PER = @"X-PER";
static NSString * const kX_ID  = @"X-ID";
static NSString * const kX_URL = @"X-URL";

@implementation SmartPaymentCZ

@synthesize specificSymbol = _specificSymbol;
@synthesize variableSymbol = _variableSymbol;
@synthesize constantSymbol = _constantSymbol;
@synthesize customIdentifier = _customIdentifier;
@synthesize customURL = _customURL;
@synthesize repeatDaysCount = _repeatDaysCount;

- (BOOL) validatePaymentWithConfiguration:(SmartPaymentConfiguration*)configuration
{
	BOOL valid = [super validatePaymentWithConfiguration:configuration];
	if (valid) {
		if ([self.account.countryCode isEqualToString:@"CZ"]) {
			valid = [self.account isValidCzechBankAccount];
		}
	}
	return valid;
}

- (NSDictionary*) validationRules
{
	NSMutableDictionary * rules = [NSMutableDictionary dictionaryWithDictionary:[super validationRules]];
	NSDictionary * czRules = [NSDictionary dictionaryWithObjectsAndKeys:
							  SPD_TAG_P(kX_KS,  SmartPaymentValueType_NumberStr, @1, @10)
							  SPD_TAG_P(kX_VS,  SmartPaymentValueType_NumberStr, @1, @10)
							  SPD_TAG_P(kX_SS,  SmartPaymentValueType_NumberStr, @1, @10)
							  SPD_TAG_P(kX_PER, SmartPaymentValueType_Number,    @0, @30)
							  SPD_TAG_P(kX_ID,  SmartPaymentValueType_String,    @1, @20)
							  SPD_TAG_P(kX_URL, SmartPaymentValueType_String,    @1, @140, @(TRUE))
							  nil];
	[rules addEntriesFromDictionary:czRules];
	return rules;
}

- (void) readPaymentFromDictionary:(NSDictionary *)dictionary
{
	[super readPaymentFromDictionary:dictionary];
	
	_variableSymbol		= [dictionary objectForKey:kX_VS];
	_specificSymbol		= [dictionary objectForKey:kX_SS];
	_constantSymbol		= [dictionary objectForKey:kX_KS];
	_customIdentifier	= [dictionary objectForKey:kX_ID];
	_customURL			= [dictionary objectForKey:kX_URL];
	_repeatDaysCount	= [dictionary objectForKey:kX_PER];
}

- (void) writePaymentToDictionary:(NSMutableDictionary *)dictionary
{
	[super writePaymentToDictionary:dictionary];
	
	[dictionary setOptionalObject:_variableSymbol forKey:kX_VS];
	[dictionary setOptionalObject:_specificSymbol forKey:kX_SS];
	[dictionary setOptionalObject:_constantSymbol forKey:kX_KS];
	[dictionary setOptionalObject:_customIdentifier forKey:kX_ID];
	[dictionary setOptionalObject:_customURL forKey:kX_URL];
	[dictionary setOptionalObject:_repeatDaysCount forKey:kX_URL];
}

+ (SmartPaymentConfiguration*) czechConfiguration
{
	return [[SmartPaymentConfiguration alloc] initWithTimeZone:[NSTimeZone timeZoneWithName:@"CET"]
												  currencyCode:@"CZK"
												  paymentClass:[SmartPaymentCZ class]
												  accountClass:nil];
}

- (NSArray*) czAllAccountsWithBankCode:(NSString*)bankCode
{
	NSArray * array = [self allAccountsForCountry:@"CZ"];
	if (bankCode) {
		NSMutableArray * result = [NSMutableArray arrayWithCapacity:array.count];
		for (SmartPaymentAccount * account in array) {
			if ([account isValidCzechBankAccount]) {
				if ([[account czBankCode] isEqualToString:bankCode]) {
					[result addObject:account];
				}
			}
		}
		return result;
	}
	return array;
}


@end



@implementation SmartPaymentAccount (CZ)

NSString * removeLeadingZeros(NSString * str)
{
	NSUInteger index = 0, count = str.length;
	while (index < count) {
		unichar uc = [str characterAtIndex:index];
		if (uc != '0') {
			break;
		}
		index++;
	}
	return [str substringFromIndex:index];
}

- (BOOL) isValidCzechBankAccount
{
	if (self.iban.length != 24) {
		return NO;
	}
	
	if (![self.countryCode isEqualToString:@"CZ"]) {
		return NO;
	}
	
	NSString * number = [self czAccountNumber];
	NSString * prefix = [self czPrefixNumber];
	
	BOOL valid = NO;
	if (number.length > 0) {
		valid = [SmartPaymentUtils isBankModulo11:number];
		if (valid && (prefix.length > 0)) {
			valid = [SmartPaymentUtils isBankModulo11:prefix];
		}
	}
	return valid;
}

- (NSString*) czBankCode
{
	if (self.iban.length != 24) {
		return nil;
	}
	return [self.iban substringWithRange:NSMakeRange(4, 4)];
}

- (NSString*) czPrefixNumber
{
	if (self.iban.length != 24) {
		return nil;
	}
	NSString * str = [self.iban substringWithRange:NSMakeRange(8, 6)];
	return removeLeadingZeros(str);
}

- (NSString*) czAccountNumber
{
	if (self.iban.length != 24) {
		return nil;
	}
	NSString * str = [self.iban substringWithRange:NSMakeRange(14, 10)];
	return removeLeadingZeros(str);
}

@end