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
	NSString * _validCode3;
	NSString * _validCode4;
}

@end

@implementation SmartPaymentReaderTests

- (void) setUp
{
	_reader = [[SmartPaymentReader alloc] initWithConfiguration:[SmartPaymentCZ czechConfiguration]];
	
	_validCode1 = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*RF:1234567890123456*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";
	_validCode2 = @"SPD*1.0*ACC:CZ5855000000001265098001+RZBCCZPP*AM:480.50*CC:CZK*RF:1234567890123456*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";


	// Note: The space after the * delimiter is left intentionally.
	// The 1.1 Standards use this string as an example, although the whitespace is probably a mistake.

	// Standing payment
	_validCode3 = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*FRQ:1M*DT:20120524*DL:20130524* DH:0";

	// Direct debit
	_validCode4 = @"SCD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*FRQ:1M*DT:20120524*DL:20130524* DH:0";
}

- (void) testValidIBAN
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode1];
	XCTAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		XCTAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
	}
}

- (void) testValidIBANandBIC
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode2];
	XCTAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		XCTAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
		XCTAssertTrue([pay.account.bic isEqualToString:@"RZBCCZPP"], @"Wrong BIC");
	}
}

- (void) testValidCode
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode1];
	XCTAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		XCTAssertTrue(pay.type == SmartPaymentTypeSinglePayment, @"Wrong payment type");
		XCTAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
		XCTAssertTrue([pay.amount isEqualToNumber:@480.50], @"Wrong Amount");
		XCTAssertTrue([pay.currencyCode isEqualToString:@"CZK"], @"Wrong currency code");
		XCTAssertTrue([pay.identifierForReceiver isEqualToString:@"1234567890123456"], @"Wrong identifier for receiver");
		XCTAssertTrue([pay.messageForReceiver isEqualToString:@"PLATBA ZA ZBOZI"], @"Wrong message for receiver");
		NSTimeInterval testDate = 1337810400;	// you can use http://www.epochconverter.com/ site for validation
		XCTAssertTrue(pay.dueDate.timeIntervalSince1970 == testDate, @"Wrong due date");
	}
}

- (void) testValidStandingOrder
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode3];
	XCTAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		XCTAssertTrue(pay.type == SmartPaymentTypeStandingOrder, @"Wrong payment type");
		XCTAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
		XCTAssertTrue(pay.amount.doubleValue == 480.50, @"Wrong Amount");
		XCTAssertTrue([pay.currencyCode isEqualToString:@"CZK"], @"Wrong Amount");
		XCTAssertTrue([pay.frequency isEqualToString:@"1M"], @"Wrong Frequency");
		NSTimeInterval testDate = 1337810400;    // you can use http://www.epochconverter.com/ site for validation
		XCTAssertTrue(pay.dueDate.timeIntervalSince1970 == testDate, @"Wrong due date");
		testDate = 1369346400;    // you can use http://www.epochconverter.com/ site for validation
		XCTAssertTrue(pay.lastDate.timeIntervalSince1970 == testDate, @"Wrong last date");
		XCTAssertTrue(pay.deathHandling.boolValue == NO, @"Wrong death handling strategy.");
	}
}

- (void) testValidDirectDebit
{
	SmartPayment * payment = [_reader createPaymentFromCode:_validCode4];
	XCTAssertTrue(payment != nil, @"SmartPaymentCZ creation failed");
	if (payment) {
		SmartPayment * pay = payment;
		XCTAssertTrue(pay.type == SmartPaymentTypeDirectDebit, @"Wrong payment type");
		XCTAssertTrue([pay.account.iban isEqualToString:@"CZ5855000000001265098001"], @"Wrong IBAN");
		XCTAssertTrue(pay.amount.doubleValue == 480.50, @"Wrong Amount");
		XCTAssertTrue([pay.currencyCode isEqualToString:@"CZK"], @"Wrong Amount");
		XCTAssertTrue([pay.frequency isEqualToString:@"1M"], @"Wrong Frequency");
		NSTimeInterval testDate = 1337810400;    // you can use http://www.epochconverter.com/ site for validation
		XCTAssertTrue(pay.dueDate.timeIntervalSince1970 == testDate, @"Wrong due date");
		testDate = 1369346400;    // you can use http://www.epochconverter.com/ site for validation
		XCTAssertTrue(pay.lastDate.timeIntervalSince1970 == testDate, @"Wrong last date");
		XCTAssertTrue(pay.deathHandling.boolValue == NO, @"Wrong death handling strategy.");
	}
}

- (void) testWrongValues
{
	SmartPayment * pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098021"];
	XCTAssertTrue(pay == nil, @"IBAN validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*"];
	XCTAssertTrue(pay != nil, @"IBAN validation is wrong. Asterisk at the end is optional but valid.");
	
	pay = [_reader createPaymentFromCode:@"SPD*9.9*ACC:CZ5855000000001265098001"];
	XCTAssertTrue(pay == nil, @"Wrong version check");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:*RN:1"];
	XCTAssertTrue(pay != nil, @"Empty value must be ignored");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:*"];
	XCTAssertTrue(pay != nil, @"Empty value must be ignored");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:"];
	XCTAssertTrue(pay != nil, @"Empty value must be ignored");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:123,0"];
	XCTAssertTrue(pay == nil, @"AM validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*AM:123.00"];
	XCTAssertTrue(pay != nil, @"AM without currency must be allowed");
	XCTAssertTrue([pay.currencyCode isEqualToString:@"CZK"], @"Substituted currency code is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*CC:CZ"];
	XCTAssertTrue(pay == nil, @"CC validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*CC:CZKK"];
	XCTAssertTrue(pay == nil, @"CC validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*RF:uydfuy38478743"];
	XCTAssertTrue(pay == nil, @"RF validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*RF:12345678901234560"];
	XCTAssertTrue(pay == nil, @"RF validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*RN:123456789 123456789 123456789 12345xxxxxxxxxxx"];
	XCTAssertTrue(pay != nil, @"RN validation is wrong");
	XCTAssertTrue([pay.receiversName isEqualToString:@"123456789 123456789 123456789 12345"], @"RN should be cropped to maximum length");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*MSG:123456789 123456789 123456789 123456789 123456789 123456789 xxxx"];
	XCTAssertTrue(pay != nil, @"MSG validation is wrong");
	XCTAssertTrue([pay.messageForReceiver isEqualToString:@"123456789 123456789 123456789 123456789 123456789 123456789 "], @"MSG should be cropped to maximum length");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*DT:2012 10 10"];
	XCTAssertTrue(pay == nil, @"DT validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*DT:20129999"];
	XCTAssertTrue(pay == nil, @"DT validation is wrong");

	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*PT:2222"];
	XCTAssertTrue(pay == nil, @"PT validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*NT:X"];
	XCTAssertTrue(pay == nil, @"NT validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*NT:P"];
	XCTAssertTrue(pay != nil, @"NT validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*NT:E"];
	XCTAssertTrue(pay != nil, @"NT validation is wrong");
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*WRONG:XXX"];
	XCTAssertTrue(pay == nil, @"Known tags validation is wrong");
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*X-UNKNOWN:XXX"];
	XCTAssertTrue(pay != nil, @"X-TAG validation is wrong");
}

- (void) testAlternateAccounts
{
	SmartPayment * pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*ALT-ACC:CZ3208000000000000007894,CZ0908000000000353497163,AT736000000002386492"];
	XCTAssertTrue(pay != nil, @"ALT-ACC validation is wrong");
	if (pay)
	{
		NSArray * allAccounts = [pay allAccounts];
		XCTAssertTrue(allAccounts.count == 4, @"Wrong ALT-ACC parser.");
	}
	
	pay = [_reader createPaymentFromCode:@"SPD*1.0*ACC:CZ5855000000001265098001*ALT-ACC:CZ3208000000000000007894,CZ0908000000000353497163,AT736000010002386492"];
	XCTAssertTrue(pay == nil, @"ALT-ACC validation is wrong. Wrong IBAN passed over tests");
}

@end
