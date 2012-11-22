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

#import "SmartPaymentReaderTests.h"
#import "SmartPaymentReader.h"
#import "SmartPaymentCZ.h"

@interface SmartPaymentReaderTests()
{
	SmartPaymentReader * _reader;
	NSString * _validCode1;
	NSString * _validCode2;
}

@end

@implementation SmartPaymentReaderTests

- (void) setUp
{
	_reader = [[SmartPaymentReader alloc] initWithConfiguration:[SmartPaymentCZ czechConfiguration]];
	
	_validCode1 = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*RF:1234567890123456*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";
	_validCode2 = @"SPD*1.0*ACC:CZ5855000000001265098001+RZBCCZPP*AM:480.50*CC:CZK*RF:1234567890123456*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";
}

- (void) testValidIBAN
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode1];
	STAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		STAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
	}
}

- (void) testValidIBANandBIC
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode2];
	STAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		STAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
		STAssertTrue([pay.account.bic isEqualToString:@"RZBCCZPP"], @"Wrong BIC");
	}
}

- (void) testValidCode
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode1];
	STAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		STAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
		STAssertTrue([pay.amount isEqualToNumber:@480.50], @"Wrong Amount");
		STAssertTrue([pay.currencyCode isEqualToString:@"CZK"], @"Wrong currency code");
		STAssertTrue([pay.identifierForReceiver isEqualToString:@"1234567890123456"], @"Wrong identifier for receiver");
		STAssertTrue([pay.messageForReceiver isEqualToString:@"PLATBA ZA ZBOZI"], @"Wrong message for receiver");
		NSTimeInterval testDate = 1337810400;	// you can use http://www.epochconverter.com/ site for validation
		STAssertTrue(pay.dueDate.timeIntervalSince1970 == testDate, @"Wrong due date");
	}
}

- (void) testWrongValues
{
	SmartPayment * pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098021"];
	STAssertTrue(pay == nil, @"IBAN validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*"];
	STAssertTrue(pay != nil, @"IBAN validation is wrong. Asterisk at the end is optional but valid.");
	
	pay = [_reader createPaymentFromCode:@"SPD*9.9*ACC:CZ5855000000001265098001"];
	STAssertTrue(pay == nil, @"Wrong version check");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:*RN:1"];
	STAssertTrue(pay != nil, @"Empty value must be ignored");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:*"];
	STAssertTrue(pay != nil, @"Empty value must be ignored");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:"];
	STAssertTrue(pay != nil, @"Empty value must be ignored");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:123,0"];
	STAssertTrue(pay == nil, @"AM validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:123.00"];
	STAssertTrue(pay != nil, @"AM without currency must be allowed");
	STAssertTrue([pay.currencyCode isEqualToString:@"CZK"], @"Substituted currency code is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*CC:CZ"];
	STAssertTrue(pay == nil, @"CC validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*CC:CZKK"];
	STAssertTrue(pay == nil, @"CC validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*RF:uydfuy38478743"];
	STAssertTrue(pay == nil, @"RF validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*RF:12345678901234560"];
	STAssertTrue(pay == nil, @"RF validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*RN:123456789 123456789 123456789 12345xxxxxxxxxxx"];
	STAssertTrue(pay != nil, @"RN validation is wrong");
	STAssertTrue([pay.receiversName isEqualToString:@"123456789 123456789 123456789 12345"], @"RN should be cropped to maximum length");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*MSG:123456789 123456789 123456789 123456789 123456789 123456789 xxxx"];
	STAssertTrue(pay != nil, @"MSG validation is wrong");
	STAssertTrue([pay.messageForReceiver isEqualToString:@"123456789 123456789 123456789 123456789 123456789 123456789 "], @"MSG should be cropped to maximum length");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*DT:2012 10 10"];
	STAssertTrue(pay == nil, @"DT validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*DT:20129999"];
	STAssertTrue(pay == nil, @"DT validation is wrong");

	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*PT:2222"];
	STAssertTrue(pay == nil, @"PT validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*NT:X"];
	STAssertTrue(pay == nil, @"NT validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*NT:P"];
	STAssertTrue(pay != nil, @"NT validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*NT:E"];
	STAssertTrue(pay != nil, @"NT validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*WRONG:XXX"];
	STAssertTrue(pay == nil, @"Known tags validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-UNKNOWN:XXX"];
	STAssertTrue(pay != nil, @"X-TAG validation is wrong");
}

- (void) testAlternateAccounts
{
	SmartPayment * pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*ALT-ACC:CZ3208000000000000007894,CZ0908000000000353497163,AT736000000002386492"];
	STAssertTrue(pay != nil, @"ALT-ACC validation is wrong");
	if (pay)
	{
		NSArray * allAccounts = [pay allAccounts];
		STAssertTrue(allAccounts.count == 4, @"Wrong ALT-ACC parser.");
	}
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*ALT-ACC:CZ3208000000000000007894,CZ0908000000000353497163,AT736000010002386492"];
	STAssertTrue(pay == nil, @"ALT-ACC validation is wrong. Wrong IBAN passed over tests");
}

@end
