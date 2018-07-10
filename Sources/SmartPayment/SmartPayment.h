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

#import "SmartPaymentAccount.h"

// The SmartPayment interface implements basic model class for smart payment.

@interface SmartPayment : NSObject<NSCopying>

// Methods for subclassing
- (void) readPaymentFromDictionary:(NSDictionary *)dictionary;
- (void) writePaymentToDictionary:(NSMutableDictionary*)dictionary;
- (BOOL) validatePaymentWithConfiguration:(SmartPaymentConfiguration*)configuration;

- (NSDictionary*) validationRules;


@property (nonatomic, assign) BOOL isValid;

// Payment type - Computed property based on parameters and header.
@property (nonatomic) SmartPaymentType type;

// Protocol header: v1.1 defines SCD and SPD.
@property (nonatomic, strong) NSString * header;

// Version property keeps version of SmartPayment. If not set during the string building then default value is used.
@property (nonatomic, strong) NSString * version;

// Primary account
@property (nonatomic, strong) SmartPaymentAccount * account;

// Contains array of alternate accounts (SmartPaymentAccount objects)
@property (nonatomic, strong) NSArray  * alternateAccounts;

// Amoun stored in decimal number.
@property (nonatomic, strong) NSDecimalNumber * amount;

// Currency code 
@property (nonatomic, strong) NSString * currencyCode;

// "RF" attribute
@property (nonatomic, strong) NSString * identifierForReceiver;

// "RN" attribute
@property (nonatomic, strong) NSString * receiversName;

// "DT" attribute
@property (nonatomic, strong) NSDate * dueDate;

// "PT" attribute
@property (nonatomic, strong) NSString * paymentType;

// "MSG" attribute
@property (nonatomic, strong) NSString * messageForReceiver;

// "NT" attribute
@property (nonatomic, assign) SmartPaymentNotificationChannel notificationChannel;

// "NTA" attribute
@property (nonatomic, strong) NSString * notificationAddress;

// "FRQ" attribute
@property (nonatomic, strong) NSString * frequency;

// "DL" attribute
@property (nonatomic, strong) NSDate * lastDate;

// "DH" attribute
@property (nonatomic, strong) NSNumber * deathHandling;

// Returns all accounts in one array.
- (NSArray*) allAccounts;

// Returns all accounts which are valid for specific country code.
- (NSArray*) allAccountsForCountry:(NSString*)ibanCountryCode;

@end
