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

#import "SmartPaymentAccount.h"

@implementation SmartPaymentAccount

@synthesize iban, bic;

- (id) initWithString:(NSString *)str
{
	self = [super init];
	if (self) {
		NSRange range = [str rangeOfString:@" "];
		if (range.length == 0) {
			iban = str;
		} else {
			iban = [str substringToIndex:range.location];
			bic = [str substringFromIndex:range.location + 1];
		}
	}
	return self;
}

- (id) initWithIBAN:(NSString *)anIban withBIC:(NSString *)aBic
{
	self = [super init];
	if (self) {
		iban = anIban;
		bic = aBic;
	}
	return self;
}


- (id) copyWithZone:(NSZone *)zone
{
	SmartPaymentAccount * acc = [[self.class allocWithZone:zone] initWithIBAN:iban withBIC:bic];

	return acc;
}

- (NSString*) description
{
	if (bic) {
		return [NSString stringWithFormat:@"%@ %@", iban, bic];
	}
	return iban;
}

- (NSString*) countryCode
{
	if (iban.length >= 2) {
		return [iban substringToIndex:2];
	}
	return nil;
}

@end
