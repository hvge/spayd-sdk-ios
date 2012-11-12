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

#import "SmartPaymentConfiguration.h"
#import "SmartPayment.h"

@interface SmartPaymentConfiguration()
{
	NSTimeZone * _timeZone;
	NSString * _currencyCode;
	Class _paymentClass;
	Class _accountClass;
}

@end

@implementation SmartPaymentConfiguration

@synthesize useCRC32InWriter = _useCRC32InWriter;
@synthesize useUpperCaseStringsInWriter = _useUpperCaseStringsInWriter;

- (id) initWithTimeZone:(NSTimeZone *)timeZone
		   currencyCode:(NSString *)currencyCode
		   paymentClass:(Class)aPaymentClass
		   accountClass:(Class)anAccountClass
{
	self = [super init];
	if (self) {
		_timeZone = timeZone;
		_currencyCode = currencyCode;
		_paymentClass = aPaymentClass ? aPaymentClass : [SmartPayment class];
		_accountClass = anAccountClass ? anAccountClass : [SmartPaymentAccount class];
	}
	return self;
}

- (NSTimeZone*) timeZone
{
	return _timeZone;
}

- (NSString*) currencyCode
{
	return _currencyCode;
}

- (Class) classForSmartPayment
{
	return _paymentClass;
}

- (Class) classForSmartPaymentAccount
{
	return _accountClass;
}

@end
