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

@interface SmartPaymentUtils : NSObject

+ (NSUInteger) calculateMod97:(NSString*)number;
+ (BOOL) isBankModulo11:(NSString*)number;

+ (NSString*) crc32:(NSString*)string;
//+ (NSString*) crc32FromAttributes:(NSDictionary*)attributes version:(NSString*)version;

@end


@interface NSMutableDictionary (SPD_OptionalObject)

- (void) setOptionalObject:(id)object forKey:(id)key;

@end