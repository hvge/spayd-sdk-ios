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

#import "SmartPaymentReaderTestsCZ.h"
#import "SmartPaymentReader.h"
#import "SmartPaymentCZ.h"

@interface SmartPaymentReaderTestsCZ()
{
	SmartPaymentReader * _reader;
	NSString * _validCode1;
	NSString * _validCode2;
}

@end

@implementation SmartPaymentReaderTestsCZ

- (void) setUp
{
	_reader = [[SmartPaymentReader alloc] initWithConfiguration:[SmartPaymentCZ czechConfiguration]];
	_validCode1 = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*RF:7004139146*X-VS:1234567890*X-SS:00123*X-KS:0200*DT:20120524*MSG:PLATBA ZA ZBOZI*X-PER:7*X-ID:0x336699*X-URL:HTTP://GOOGLE.COM";
	
	_validCode2 = @"SPD*1.0*ACC:CZ5855000000001265098001*ALT-ACC:CZ3208000000000000007894,CZ0908000000000353497163,AT736000000002386492";
}

- (void) testCZCodes
{
	NSString * qrcode = _validCode1;
	SmartPayment * payment = [_reader createPaymentFromCode:qrcode];
	STAssertTrue(payment != nil, @"CZ: SmartPaymentCZ creation failed");
	if (payment) {
		SmartPaymentCZ * pay = [payment isKindOfClass:[SmartPaymentCZ class]] ? (SmartPaymentCZ*)payment : nil;
		
		STAssertTrue(pay != nil, @"CZ: Wrong payment object type");
		
		STAssertTrue([pay.specificSymbol isEqualToString:@"00123"],			@"CZ: Wrong Specific Symbol");
		STAssertTrue([pay.variableSymbol isEqualToString:@"1234567890"],	@"CZ: Wrong Variable Symbol");
		STAssertTrue([pay.constantSymbol isEqualToString:@"0200"],			@"CZ: Wrong Constant Symbol");
		STAssertTrue([pay.repeatDaysCount isEqualToNumber:@7],				@"CZ: Wrong Repeat days count");
		STAssertTrue([pay.customIdentifier isEqualToString:@"0x336699"],	@"CZ: Wrong custom identifier");
		STAssertTrue([pay.customURL isEqualToString:@"HTTP://GOOGLE.COM"],	@"CZ: Wrong custom URL");
	}
	
	payment = [_reader createPaymentFromCode:_validCode2];
	STAssertTrue(payment != nil, @"CZ: SmartPaymentCZ creation failed");
	if (payment) {
		SmartPaymentCZ * pay = [payment isKindOfClass:[SmartPaymentCZ class]] ? (SmartPaymentCZ*)payment : nil;
		NSArray * accounts = [payment allAccountsForCountry:@"CZ"];
		STAssertTrue(accounts.count == 3, @"CZ: wrong country filter");
		accounts = [pay czAllAccountsWithBankCode:@"5500"];
		STAssertTrue(accounts.count == 1, @"CZ: wrong bank filter");
		accounts = [pay czAllAccountsWithBankCode:@"0800"];
		STAssertTrue(accounts.count == 2, @"CZ: wrong bank filter");

	}
}

- (void) testWrongCZCodes
{	
	SmartPayment * payment = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-VS:12345678901"];
	STAssertTrue(payment == nil, @"CZ: wrong X-VS length test");
	payment = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-SS:12345678901"];
	STAssertTrue(payment == nil, @"CZ: wrong X-SS length test");
	payment = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-KS:12345678901"];
	STAssertTrue(payment == nil, @"CZ: wrong X-KS length test");
	payment = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-ID:123456789012345678901"];
	STAssertTrue(payment == nil, @"CZ: wrong X-ID length test");
	payment = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-PER:0"];
	STAssertTrue(payment == nil, @"CZ: wrong X-PER length test");
	payment = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-PER:31"];
	STAssertTrue(payment == nil, @"CZ: wrong X-PER length test");
}

@end
