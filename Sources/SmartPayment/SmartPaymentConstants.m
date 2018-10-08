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

#import "SmartPaymentConstants.h"

// Header & Version

NSString * const kSmartPayment_Header	= @"SPD";
NSString * const kSmartDebit_Header		= @"SCD";
NSString * const kSmartPayment_Version	= @"1.0";

// Keys

NSString * const kSmartPaymentKey_Header = @"HEADER";

// TAGS

NSString * const kSmartPaymentTag_Account				= @"ACC";
NSString * const kSmartPaymentTag_AlternateAccounts		= @"ALT-ACC";
NSString * const kSmartPaymentTag_Amount				= @"AM";
NSString * const kSmartPaymentTag_CurrencyCode			= @"CC";
NSString * const kSmartPaymentTag_IdentifierForReceiver	= @"RF";
NSString * const kSmartPaymentTag_ReceiversName			= @"RN";
NSString * const kSmartPaymentTag_PaymentType			= @"PT";
NSString * const kSmartPaymentTag_DueDate				= @"DT";
NSString * const kSmartPaymentTag_MessageForReceiver	= @"MSG";
NSString * const kSmartPaymentTag_NotificationChannel	= @"NT";
NSString * const kSmartPaymentTag_NotificationAddress	= @"NTA";
NSString * const kSmartPaymentTag_CRC32					= @"CRC32";
NSString * const kSmartPaymentTag_LastDate				= @"DL";
NSString * const kSmartPaymentTag_Frequency				= @"FRQ";
NSString * const kSmartPaymentTag_DeathHandling			= @"DH";


NSArray * SmartPayment_GetRecommendedTagsOrder()
{
	return [NSArray arrayWithObjects:
			kSmartPaymentTag_Account,
			kSmartPaymentTag_AlternateAccounts,
			kSmartPaymentTag_Amount,
			kSmartPaymentTag_CurrencyCode,
			kSmartPaymentTag_IdentifierForReceiver,
			kSmartPaymentTag_ReceiversName,
			kSmartPaymentTag_DueDate,
			kSmartPaymentTag_PaymentType,
			kSmartPaymentTag_MessageForReceiver,
			kSmartPaymentTag_NotificationChannel,
			kSmartPaymentTag_NotificationAddress,
			kSmartPaymentTag_CRC32,
			kSmartPaymentTag_LastDate,
			kSmartPaymentTag_Frequency,
			kSmartPaymentTag_DeathHandling,
			nil];
}

NSSet * SmartPayment_GetKnownTags()
{
	return [NSSet setWithArray:SmartPayment_GetRecommendedTagsOrder()];
}

// Error descriptor

NSString * const kSmartPaymentErrorDomain = @"cz.qr-platba.error";
