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

#ifndef __SmartPaymentConstants_h_defined__
#define __SmartPaymentConstants_h_defined__

#import <Foundation/Foundation.h>

// Header & Supported version

extern NSString * const kSmartPayment_Header;
extern NSString * const kSmartDebit_Header;
extern NSString * const kSmartPayment_Version;

// Keys

extern NSString * const kSmartPaymentKey_Header;

// Default TAGS

extern NSString * const kSmartPaymentTag_Account;				// AM
extern NSString * const kSmartPaymentTag_AlternateAccounts;		// ALT-ACC
extern NSString * const kSmartPaymentTag_Amount;				// AM
extern NSString * const kSmartPaymentTag_CurrencyCode;			// CC
extern NSString * const kSmartPaymentTag_IdentifierForReceiver;	// RF
extern NSString * const kSmartPaymentTag_ReceiversName;			// RN
extern NSString * const kSmartPaymentTag_PaymentType;			// PT
extern NSString * const kSmartPaymentTag_DueDate;				// DT
extern NSString * const kSmartPaymentTag_MessageForReceiver;	// MSG
extern NSString * const kSmartPaymentTag_NotificationChannel;	// NT
extern NSString * const kSmartPaymentTag_NotificationAddress;	// NTA
extern NSString * const kSmartPaymentTag_CRC32;					// CRC32
extern NSString * const kSmartPaymentTag_LastDate;				// DL
extern NSString * const kSmartPaymentTag_Frequency;				// FRQ
extern NSString * const kSmartPaymentTag_DeathHandling;			// DH

extern NSSet *   SmartPayment_GetKnownTags();
extern NSArray * SmartPayment_GetRecommendedTagsOrder();


// Errors

extern NSString * const kSmartPaymentErrorDomain;

typedef enum {
	SmartPaymentError_NotAPayment = 0,				// Parsed string doesn't contain SPD header
	SmartPaymentError_UnsupportedVersion,			// Unsupported version of smart payment
	SmartPaymentError_MissingRequiredAttributes,	// Payment doesn't contain ACC field or other required attributes
	SmartPaymentError_DataError,					// Validation performed on some attributes did fail.
	SmartPaymentError_EncodingError,				// Unable to create NSString from input NSData.
	SmartPaymentError_WrongChecksum,				// CRC32 checksum is wrong
} SmartPaymentErrorCode;


// The SmartPaymentNotificationChannel enumeration declares types of notification channels.

typedef enum {
	SmartPaymentNotificationChannel_None,		// Without notification
	SmartPaymentNotificationChannel_Phone,		// Notification via phone
	SmartPaymentNotificationChannel_EMail,		// Notification via e-mail
} SmartPaymentNotificationChannel;


// Constants for tag definition dictionary

typedef enum {
	SmartPaymentValueType_Amount,		// amount
	SmartPaymentValueType_IBAN,			// account in IBAN form
	SmartPaymentValueType_IBANs,		// comma separated list of IBANs
	SmartPaymentValueType_Number,		// number
	SmartPaymentValueType_String,		// regular string
	SmartPaymentValueType_NumberStr,	// value must be number but validator will keep its string representation
	SmartPaymentValueType_RegExp,		// regular expression for validation, the paramter contains regexp
	SmartPaymentValueType_Enum,			// value must be one from strings array
	SmartPaymentValueType_Date,			// date
	SmartPaymentValueType_Frequency,	// standing order frequency
	SmartPaymentValueType_Boolean		// boolean
} SmartPaymentValueType;

typedef enum {
	SmartPaymentTypeSinglePayment,
	SmartPaymentTypeStandingOrder,
	SmartPaymentTypeDirectDebit,
} SmartPaymentType;

#define SPD_TAG(tagName, valueType)										\
																		\
	[NSArray arrayWithObject:											\
		[NSNumber numberWithInt:valueType]								\
	],																	\
	tagName,

#define SPD_TAG_P(tagName, valueType, params...)						\
																		\
	[NSArray arrayWithObjects:											\
		[NSNumber numberWithInt:valueType],								\
		[NSArray arrayWithObjects:params, nil],							\
		nil																\
	],																	\
	tagName,

#endif //__SmartPaymentConstants_m_defined__
