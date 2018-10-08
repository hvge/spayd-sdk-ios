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

#import "SmartPaymentUtils.h"
#include <zlib.h>

@implementation SmartPaymentUtils

#pragma mark - Modulo calculations

static inline NSUInteger IntegerValue(unichar uc)
{
	if (uc >= '0' && uc <= '9') {
		return uc - '0';
	}
	return uc - 'A' + 10;
}


+ (NSUInteger) calculateMod97:(NSString *)str
{
	NSUInteger length = str.length;
	NSUInteger checkSum = 0;
	for (NSUInteger index = 0; index < length; index++) {
		NSUInteger value = IntegerValue([str characterAtIndex:index]);
		if (value < 10) {
			checkSum = (10  * checkSum) + value;
		} else {
			checkSum = (100 * checkSum) + value;
		}
		if (checkSum >= UINT_MAX / 100) {
			checkSum %= 97;
		}
	}
	return checkSum % 97;
}


+ (BOOL) isBankModulo11:(NSString*)number
{
	if (number.length < 2) {
		return NO;
	}
	long weight = 1;
	long sum = 0;
	for (int k = (int)number.length - 1; k >= 0; k--) {
		int character = [number characterAtIndex:k] - '0';
		if (character < 0 || character > 9) {
			//NSLog(@"Invalid character in account number %@", number);
			return NO;
		}
		sum += character * weight;
		weight *= 2;
	}
	
	return (sum % 11) == 0;
}

#pragma mark - CRC32

+ (NSString*) crc32:(NSString*)str
{
	const char * utf8str = [str UTF8String];
	UInt32 crc = (UInt32)crc32(0L, Z_NULL, 0);
	if (utf8str) {
		crc = (UInt32)crc32(crc, (const Bytef*)utf8str, (uInt)strlen(utf8str));
	}
	return [NSString stringWithFormat:@"%08X", (unsigned int)crc];
}

/*
+ (NSString*) crc32FromAttributes:(NSDictionary*)attributes version:(NSString*)version
{
	
}
*/

@end


#pragma mark - Helper categories

@implementation NSMutableDictionary (SPD_OptionalObject)

- (void) setOptionalObject:(id)object forKey:(id)key
{
	if (object) {
		[self setObject:object forKey:key];
	}
}

@end