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

#import "IBANValidatorTests.h"
#import "IBANValidator.h"

@interface IBANValidatorTests()
{
	NSArray * _testIBANs;
}

@end



@implementation IBANValidatorTests

- (void)setUp
{
    [super setUp];
    
	_testIBANs = [NSArray arrayWithObjects:
				  
				  // Test IBANs from wikipedia
				  @"GR1601101250000000012300695",
				  @"GB29NWBK60161331926819",
				  @"SA0380000000608010167519",
				  @"CH9300762011623852957",
				  @"IL620108000000099999999",
				  
				  // Examples from CNB
				  @"CZ6508000000192000145399",
				  @"CZ0908000000000353497163",
				  @"CZ3208000000000000007894",
				  
				  @"AT736000000002386492",	// Austria replacement for Nordea's data set. Gathered from google: "iban site:at" :)
				  
				  // Examples grabbed from
				  // http://www.nordea.com/Our%2Bservices/International%2Bproducts%2Band%2Bservices/Cash%2BManagement/IBAN%2Bcountries/908462.html
				  
				  @"AL47212110090000000235698741",
				  @"AD1200012030200359100100",
				  //@"AT611904300235473201", -- invalid
				  @"BE68539007547034",
				  @"BA391290079401028494",
				  @"BG80BNBG96611020345678",
				  @"HR1210010051863000160",
				  @"CY17002001280000001200527600",
				  @"CZ6508000000192000145399",
				  @"DK5000400440116243",
				  @"EE382200221020145685",
				  @"FO1464600009692713",
				  @"FI2112345600000785",
				  @"FR1420041010050500013M02606",
				  @"DE89370400440532013000",
				  @"GI75NWBK000000007099453",
				  @"GR1601101250000000012300695",
				  @"GL8964710001000206",
				  @"HU42117730161111101800000000",
				  @"IS140159260076545510730339",
				  @"IE29AIBK93115212345678",
				  @"IT60X0542811101000000123456",
				  @"LV80BANK0000435195001",
				  @"LI21088100002324013AA",
				  @"LT121000011101001000",
				  @"LU280019400644750000",
				  @"MK07300000000042425",
				  @"MT84MALT011000012345MTLCAST001S",
				  @"MC5813488000010051108001292",
				  @"ME25505000012345678951",
				  @"NL91ABNA0417164300",
				  @"NO9386011117947",
				  @"PL27114020040000300201355387",
				  @"PT50000201231234567890154",
				  @"RO49AAAA1B31007593840000",
				  @"SM86U0322509800000000270100",
				  @"RS35260005601001611379",
				  @"SK3112000000198742637541",
				  @"SI56191000000123438",
				  @"ES9121000418450200051332",
				  @"SE3550000000054910000003",
				  @"CH9300762011623852957",
				  @"TR330006100519786457841326",
				  @"GB29NWBK60161331926819",
				  @"AO06000600000100037131174",
				  @"BI43201011067444",
				  @"CM2110003001000500000605306",
				  @"CV64000300004547069110176",
				  @"FR7630007000110009970004942",
				  @"IR580540105180021273113007",
				  @"IL620108000000099999999",
				  @"CI05A00060174100178530011852",
				  @"KZ176010251000042993",
				  @"LB30099900000001001925579115",
				  @"MG4600005030010101914016056",
				  @"ML03D00890170001002120000447",
				  @"MZ59000100000011834194157",
				  @"SA0380000000608010167519",
				  @"TN5914207207100707129648",
				  @"AE260211000000230064016",
				  
				  // Examples from
				  // http://www.natwest.com/commercial/international/g0/guide-to-international-business/g1/regulatory-information/g12/iban/iban-examples.ashx
				  @"AL47212110090000000235698741",
				  @"AD1200012030200359100100",
				  @"AT611904300234573201",
				  @"BH67BMAG00001299123456",
				  @"BE62510007547061",
				  @"BA391290079401028494",
				  @"BG80BNBG96611020345678",
				  @"HR1210010051863000160",
				  @"CY17002001280000001200527600",
				  @"CZ6508000000192000145399",
				  @"DK5000400440116243",
				  @"EE382200221020145685",
				  @"FO9754320388899944",
				  @"FI2112345600000785",
				  @"FR1420041010050500013M02606",
				  @"GE29NB0000000101904917",
				  @"DE89370400440532013000",
				  @"GI75NWBK000000007099453",
				  @"GR1601101250000000012300695",
				  @"GL5604449876543210",
				  @"HU42117730161111101800000000",
				  @"IS140159260076545510730339",
				  @"IE29AIBK93115212345678",
				  @"IL620108000000099999999",
				  @"IT40S0542811101000000123456",
				  @"LV80BANK0000435195001",
				  @"LB62099900000001001901229114",
				  @"LI21088100002324013AA",
				  @"LT121000011101001000",
				  @"LU280019400644750000",
				  @"MK07250120000058984",
				  @"MT84MALT011000012345MTLCAST001S",
				  @"MU17BOMM0101101030300200000MUR",
				  @"MC9320052222100112233M44555",
				  @"ME25505000012345678951",
				  @"NL39RABO0300065264",
				  @"NO9386011117947",
				  @"PL60102010260000042270201111",
				  @"PT50000201231234567890154",
				  @"RO49AAAA1B31007593840000",
				  @"SM86U0322509800000000270100",
				  @"SA0380000000608010167519",
				  @"RS35260005601001611379",
				  @"SK3112000000198742637541",
				  @"SI56191000000123438",
				  @"ES8023100001180000012345",
				  @"SE3550000000054910000003",
				  @"CH9300762011623852957",
				  @"TN5910006035183598478831",
				  @"TR330006100519786457841326",
				  @"AE070331234567890123456",
				  //@"GB29RBOS60161331926819", -- invalid

				  nil];
}

- (void) testBasicIBANTest
{
	IBANValidator * validator = [[IBANValidator alloc] init];
	IBANValidationResult result = [validator validateElectronicIBAN:@"GB82WEST12345698765432"];
	XCTAssertTrue(result == IBANValidation_OK, @"Basic IBAN Test failed");
	
	result = [validator validateElectronicIBAN:@"XX4539487534957349587"];
	XCTAssertTrue(result == IBANValidation_Error, @"Basic IBAN Test failed");
	
	result = [validator validateElectronicIBAN:@"CZ650800000019200014539"];
	XCTAssertTrue(result == IBANValidation_Error, @"Basic IBAN Test failed");

	result = [validator validateElectronicIBAN:@"CZ6508001000192000145399"];
	XCTAssertTrue(result == IBANValidation_Error, @"Basic IBAN Test failed");
}

- (void) testCountryIBANs
{
	IBANValidator * validator = [[IBANValidator alloc] init];
	for (NSString * iban in _testIBANs) {
		IBANValidationResult result = [validator validateElectronicIBAN:iban];
		XCTAssertTrue(result == IBANValidation_OK, @"Test for IBAN %@ failed", iban);
	}
	
	NSLog(@"Country Test END");
}



@end
