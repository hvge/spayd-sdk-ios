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
#import "SmartPaymentConstants.h"
#import "SmartPaymentUtils.h"

@interface SmartPayment ()
{
}

@end


@implementation SmartPayment

@synthesize isValid = _isValid;
@synthesize account = _account, alternateAccounts = _alternateAccounts;
@synthesize amount = _amount, currencyCode = _currencyCode;
@synthesize identifierForReceiver = _identifierForReceiver, receiversName = _receiversName;
@synthesize dueDate = _dueDate, messageForReceiver = _messageForReceiver;
@synthesize notificationChannel = _notificationChannel;

#pragma mark - Public API

- (NSArray*) allAccounts
{
	NSMutableArray * array = [NSMutableArray array];
	if (_account) {
		[array addObject:_account];
	}
	if (_alternateAccounts) {
		[array addObjectsFromArray:_alternateAccounts];
	}
	return array;
}

- (NSArray*) allAccountsForCountry:(NSString*)ibanCountryCode
{
	NSArray * array = [self allAccounts];
	NSMutableArray * result = [NSMutableArray arrayWithCapacity:array.count];
	for (SmartPaymentAccount * account in array) {
		if ([account.countryCode isEqualToString:ibanCountryCode]) {
			[result addObject:account];
		}
	}
	return result;
}

#pragma mark - Validation

- (NSDictionary*) validationRules
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			SPD_TAG  ( kSmartPaymentTag_Account,				SmartPaymentValueType_IBAN)
			SPD_TAG  ( kSmartPaymentTag_AlternateAccounts,		SmartPaymentValueType_IBANs)
			SPD_TAG  ( kSmartPaymentTag_Amount,					SmartPaymentValueType_Amount)
			SPD_TAG_P( kSmartPaymentTag_CurrencyCode,			SmartPaymentValueType_String,	@3, @3)
			SPD_TAG_P( kSmartPaymentTag_IdentifierForReceiver,	SmartPaymentValueType_NumberStr,@1, @16)
			SPD_TAG_P( kSmartPaymentTag_ReceiversName,			SmartPaymentValueType_String,	@1, @35, @(TRUE))
			SPD_TAG  ( kSmartPaymentTag_DueDate,				SmartPaymentValueType_Date)
			SPD_TAG_P( kSmartPaymentTag_PaymentType,			SmartPaymentValueType_String,	@1, @3)
			SPD_TAG_P( kSmartPaymentTag_MessageForReceiver,		SmartPaymentValueType_String,	@1, @60, @(TRUE))
			SPD_TAG_P( kSmartPaymentTag_CRC32,					SmartPaymentValueType_String,	@8, @8)
			SPD_TAG_P( kSmartPaymentTag_NotificationChannel,	SmartPaymentValueType_Enum,		@"P", @"E")
			SPD_TAG_P( kSmartPaymentTag_NotificationAddress,	SmartPaymentValueType_String,	@1,  @320, @(TRUE))
			SPD_TAG  ( kSmartPaymentTag_LastDate,				SmartPaymentValueType_Date)
			SPD_TAG  ( kSmartPaymentTag_Frequency,				SmartPaymentValueType_Frequency)
			SPD_TAG_P( kSmartPaymentTag_DeathHandling,			SmartPaymentValueType_Number,	@0,	@1)
			nil];
}

- (BOOL) validatePaymentWithConfiguration:(SmartPaymentConfiguration*)configuration
{
	BOOL valid = _account != nil;
	if (_amount) {
		if (!_currencyCode) {
			_currencyCode = configuration.currencyCode;
		}
		valid = valid && (_currencyCode != nil);
	}
	// TODO: add validation for email/notification address
	return valid;
}

#pragma mark - Read data

- (void) readPaymentFromDictionary:(NSDictionary *)dictionary
{
	_header					= [dictionary objectForKey:kSmartPaymentKey_Header];
	_account				= [dictionary objectForKey:kSmartPaymentTag_Account];
	_alternateAccounts		= [dictionary objectForKey:kSmartPaymentTag_AlternateAccounts];
	_amount					= [dictionary objectForKey:kSmartPaymentTag_Amount];
	_currencyCode			= [dictionary objectForKey:kSmartPaymentTag_CurrencyCode];
	_identifierForReceiver	= [dictionary objectForKey:kSmartPaymentTag_IdentifierForReceiver];
	_receiversName			= [dictionary objectForKey:kSmartPaymentTag_ReceiversName];
	_dueDate				= [dictionary objectForKey:kSmartPaymentTag_DueDate];
	_paymentType			= [dictionary objectForKey:kSmartPaymentTag_PaymentType];
	_messageForReceiver		= [dictionary objectForKey:kSmartPaymentTag_MessageForReceiver];
	_frequency				= [dictionary objectForKey:kSmartPaymentTag_Frequency];
	_lastDate				= [dictionary objectForKey:kSmartPaymentTag_LastDate];
	_deathHandling			= [dictionary objectForKey:kSmartPaymentTag_DeathHandling];

	id value = [dictionary objectForKey:kSmartPaymentTag_NotificationChannel];
	if (value) {
		_notificationChannel = [value intValue];
	} else {
		_notificationChannel = SmartPaymentNotificationChannel_None;
	}
	_notificationAddress	= [dictionary objectForKey:kSmartPaymentTag_NotificationAddress];
}

#pragma mark - Write data

- (void) writePaymentToDictionary:(NSMutableDictionary *)dictionary
{
	[dictionary setOptionalObject:_account forKey:kSmartPaymentTag_Account];
	[dictionary setOptionalObject:_alternateAccounts forKey:kSmartPaymentTag_AlternateAccounts];
	[dictionary setOptionalObject:_amount forKey:_amount];
	[dictionary setOptionalObject:[_currencyCode uppercaseString] forKey:kSmartPaymentTag_CurrencyCode];
	[dictionary setOptionalObject:_identifierForReceiver forKey:kSmartPaymentTag_IdentifierForReceiver];
	[dictionary setOptionalObject:_receiversName forKey:kSmartPaymentTag_ReceiversName];
	[dictionary setOptionalObject:_dueDate forKey:kSmartPaymentTag_DueDate];
	[dictionary setOptionalObject:_paymentType forKey:kSmartPaymentTag_PaymentType];
	[dictionary setOptionalObject:_messageForReceiver forKey:kSmartPaymentTag_MessageForReceiver];
	[dictionary setOptionalObject:_frequency forKey:kSmartPaymentTag_Frequency];
	[dictionary setOptionalObject:_lastDate forKey:kSmartPaymentTag_LastDate];
	[dictionary setOptionalObject:_deathHandling forKey:kSmartPaymentTag_DeathHandling];

	if (_notificationChannel != SmartPaymentNotificationChannel_None) {
		[dictionary setOptionalObject:@(_notificationChannel) forKey:kSmartPaymentTag_NotificationChannel];
		[dictionary setOptionalObject:_notificationAddress forKey:kSmartPaymentTag_NotificationAddress];
	}
}

#pragma mark - NSCopying

- (id) copyWithZone:(NSZone *)zone
{
	SmartPayment * payment = [[self.class allocWithZone:zone] init];
	
	payment.version = _version;
	payment.isValid = _isValid;
	payment.account = [_account copyWithZone:zone];
	payment.alternateAccounts = [_alternateAccounts copyWithZone:zone];
	payment.amount = _amount;
	payment.currencyCode = _currencyCode;
	payment.identifierForReceiver = _identifierForReceiver;
	payment.receiversName = _receiversName;
	payment.dueDate = _dueDate;
	payment.paymentType = _paymentType;
	payment.messageForReceiver = _messageForReceiver;
	payment.notificationChannel = _notificationChannel;
	payment.notificationAddress = _notificationAddress;
	payment.frequency = _frequency;
	payment.lastDate = _lastDate;
	payment.deathHandling = _deathHandling;
	payment.header = _header;
	
	return payment;
}

#pragma mark - Computed properties

- (SmartPaymentType)type {
	if ([_header isEqualToString:kSmartPayment_Header]) {
		if (_frequency != nil) {
			return SmartPaymentTypeStandingOrder;
		} else {
			return SmartPaymentTypeSinglePayment;
		}
	} else {
		return SmartPaymentTypeDirectDebit;
	}
}

@end
