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

#import <Foundation/Foundation.h>

@interface SmartPaymentConfiguration : NSObject

- (id) initWithTimeZone:(NSTimeZone*)tz
		   currencyCode:(NSString*)currencyCode
		   paymentClass:(Class)aClass
		   accountClass:(Class)aClass;

@property (nonatomic, strong, readonly) NSTimeZone * timeZone;
@property (nonatomic, strong, readonly) NSString * currencyCode;
@property (nonatomic, strong, readonly) Class classForSmartPayment;
@property (nonatomic, strong, readonly) Class classForSmartPaymentAccount;

// Following properties are optional and allows you to change behavior
// of reader & writer before the processing.

// If YES then writer will generate CRC32 checksum (not implemented yet)
@property (nonatomic, assign) BOOL useCRC32InWriter;

// If YES then writer will generate uppercase strings only. This option also removes
// any UTF-8 encoded characters (not implemented yet)
@property (nonatomic, assign) BOOL useUpperCaseStringsInWriter;

@end
