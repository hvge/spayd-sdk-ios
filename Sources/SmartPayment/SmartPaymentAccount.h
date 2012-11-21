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
#import "SmartPaymentConstants.h"

@interface SmartPaymentAccount : NSObject<NSCopying>

// General properties

// IBAN is required property and must be set.
@property (nonatomic, strong) NSString * iban;

// BIC is an optional part of account in SmartPayment but if your country
// has BIC already as a part of IBAN then you can update missing value
// directly from IBAN. For example, IBAN for Great Britain already contains BIC.
@property (nonatomic, strong) NSString * bic;

// Contains country code extracted from first two characters of IBAN.
// The property might be nil if IBAN is not valid.
@property (nonatomic, strong, readonly) NSString * countryCode;

// Default initializer. The BIC part may be nil.
- (id) initWithIBAN:(NSString*)iban withBIC:(NSString*)bic;

// Initializes SmartPaymentAccount object with SmartPayment's string representation of account.
// If string contains optional BIC part then method automatically extracts it.
//
// NOTE: This implementation uses space as a separator between IBAN & BIC and this might be confusing.
//       The reason for that is that SmartPaymentReader already does URL decoding internally and '+' is
//       replaced with space.
- (id) initWithString:(NSString*)str;

// Returns "IBAN BIC" or just "IBAN" if BIC is nil.
- (NSString*) description;

@end
