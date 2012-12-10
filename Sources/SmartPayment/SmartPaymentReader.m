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

#import "SmartPaymentReader.h"
#import "SmartPaymentConstants.h"
#import "SmartPaymentUtils.h"
#import "SmartPaymentValidator.h"
#import "IBANValidator.h"

@interface SmartPaymentReader ()
{
	NSSet * _knownTags;
	SmartPaymentConfiguration * _configuration;
}

- (BOOL) validateCRC32:(NSDictionary*)dict code:(NSString*)code;
- (void) setupError:(SmartPaymentErrorCode)code str:(NSString*)str;

@end

@implementation SmartPaymentReader

@synthesize error = _error;

- (id) initWithConfiguration:(SmartPaymentConfiguration*)configuration
{
	self = [super init];
	if (self) {
		_knownTags = SmartPayment_GetKnownTags();
		_configuration = configuration;
	}
	return self;
}

- (SmartPayment*) createPayment
{
	Class cl = _configuration.classForSmartPayment;
	if (!cl) {
		cl = [SmartPayment class];
	}
	return [[cl alloc] init];
}

- (id) createPaymentFromCode:(NSString*)code
{
	self.error = nil;
	
	if (!_configuration) {
		NSLog(@"SmartPaymentReader: You have to initialize reader with valid configuration.");
		return nil;
	}
	
	NSDictionary * attributes = [self paymentAttributesFromCode:code];
	SmartPayment * sp = nil;
	if (attributes) {
		sp = [self createPayment];
		// TODO: setup timezone here...
		SmartPaymentValidator * validator = [[SmartPaymentValidator alloc] initWithConfiguration:_configuration];
		NSDictionary * validationRules = [sp validationRules];
		NSDictionary * validatedAttributes = [validator validateInputValues:attributes withDefinition:validationRules];
		if (validatedAttributes) {
			[sp readPaymentFromDictionary:validatedAttributes];
			sp.isValid = [sp validatePaymentWithConfiguration:_configuration];
			if (!sp.isValid) {
				sp = nil;
			}
		} else {
			sp = nil;
			self.error = [validator firstError];
		}
	}
	if (_error) {
		NSLog(@"SmartPaymentReader: Error: %@", [_error localizedDescription]);
	}
	return sp;
}

- (SmartPayment*) createPaymentFromData:(NSData*)data
{
	NSString * code = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
	if (code) {
		return [self createPaymentFromCode:code];
	}
	[self setupError:SmartPaymentError_EncodingError str:@"Unable to create unicode string from Latin-1 data."];
	return nil;
}

#pragma mark - Public API

- (NSDictionary*) paymentAttributesFromCode:(NSString*)code
{
	if ([code hasSuffix:@"*"]) {
		code = [code substringToIndex:code.length - 1];
	}
	NSArray * keyValues = [code componentsSeparatedByString:@"*"];
	
	// There must be at least 3 fields available: PAY, version, ACC
	if (keyValues.count < 3) {
		[self setupError:SmartPaymentError_NotAPayment str:@"String doesn't contain valid SmartPayment descriptor."];
		return nil;
	}
	if (![[keyValues objectAtIndex:0] isEqualToString:kSmartPayment_Header]) {
		// Not a Smart Payment string
		[self setupError:SmartPaymentError_NotAPayment str:@"String doesn't contain valid SmartPayment descriptor."];
		return nil;
	}
	if (![[keyValues objectAtIndex:1] isEqualToString:kSmartPayment_Version]) {
		// Unknown version
		[self setupError:SmartPaymentError_UnsupportedVersion str:[NSString stringWithFormat:@"Unknown SmartPayment version %@", [keyValues objectAtIndex:1]]];
		return nil;
	}
	
	NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionaryWithCapacity:keyValues.count];
	NSUInteger index = 2, count = keyValues.count;
	while (index < count)
	{
		NSString * kv = [keyValues objectAtIndex:index++];

		// Find first colon
		NSRange colonRange = [kv rangeOfString:@":"];
		if (colonRange.length == 0) {
			[self setupError:SmartPaymentError_NotAPayment str:[NSString stringWithFormat:@"Unknown token '%@'", kv]];
			return nil;
		}
		NSString * key = [kv substringToIndex:colonRange.location];
		NSString * value = [kv substringFromIndex:colonRange.location + 1];
		
		// Validate key
		if (![key hasPrefix:@"X-"] && ![_knownTags containsObject:key]) {
			[self setupError:SmartPaymentError_NotAPayment str:[NSString stringWithFormat:@"Unknown key '%@'", key]];
			return nil;
		}
		// Quick validate value
		value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
		value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (value.length == 0) {
			continue;
		}
		
		[resultDictionary setObject:value forKey:key];
	}

	if (![self validateCRC32:resultDictionary code:code]) {
		resultDictionary = nil;
	}
	
	return resultDictionary;
}


#pragma mark - Private methods

- (void) setupError:(SmartPaymentErrorCode)code str:(NSString*)str
{
	NSDictionary * userInfo = [NSDictionary dictionaryWithObject:str forKey:NSLocalizedDescriptionKey];
	_error = [NSError errorWithDomain:kSmartPaymentErrorDomain
								 code:code
							 userInfo:userInfo];
}


- (BOOL) validateCRC32:(NSDictionary*)dict code:(NSString*)code
{
	// TODO...
	return YES;
}

@end



@implementation SmartPayment (Reader)

+ (id) smartPaymentWithCode:(NSString*)code configuration:(SmartPaymentConfiguration*)configuration
{
	SmartPaymentReader * reader = [[SmartPaymentReader alloc] initWithConfiguration:configuration];
	return [reader createPaymentFromCode:code];
}

+ (id) smartPaymentWithData:(NSData*)data configuration:(SmartPaymentConfiguration*)configuration
{
	SmartPaymentReader * reader = [[SmartPaymentReader alloc] initWithConfiguration:configuration];
	return [reader createPaymentFromData:data];
}

@end
