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

#import "SmartPayment.h"
#import "SmartPaymentConfiguration.h"

// The SmartPaymentCZ class implements features required for
// domestic payments in Czech Republic.
//
// This class is also good example how to extend SmartPayment for
// other countries.
//
// Czech implementation brings following specific features:
//
// New attributes:
//		specific symbol (X-SS attribute)
//		variable symbol (X-VS attribute)
//		constant symbol (X-KS attribute)
//

@class SmartPaymentAccountCZ;

@interface SmartPaymentCZ : SmartPayment

@property (nonatomic, strong) NSString * variableSymbol;		// X-VS, Optional, up to 10 digits
@property (nonatomic, strong) NSString * constantSymbol;		// X-KS, Optional, up to 10 digits
@property (nonatomic, strong) NSString * specificSymbol;		// X-SS, Optional, up to 10 digits

@property (nonatomic, strong) NSString * customIdentifier;		// X-ID, Optional, up to 20 chars
@property (nonatomic, strong) NSString * customURL;				// X-URL, Optional, up to 140 chars

@property (nonatomic, strong) NSNumber * repeatDaysCount;		// X-PER, Optional, for how many days will payer try to realize payment

+ (SmartPaymentConfiguration*) czechConfiguration;

// Returns array with accounts which has specific bank code. If bankCode parameter is nil then method
// returns all czech bank accounts.
- (NSArray*) czAllAccountsWithBankCode:(NSString*)bankCode;

@end



@interface SmartPaymentAccount (CZ)

@property (nonatomic, readonly) BOOL isValidCzechBankAccount;

@property (nonatomic, strong, readonly) NSString * czBankCode;
@property (nonatomic, strong, readonly) NSString * czPrefixNumber;
@property (nonatomic, strong, readonly) NSString * czAccountNumber;

@end
