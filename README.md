# Smart Payment Descriptor for iOS

The **spayd-sdk-ios** project is an full iOS implementation of [Smart Payment Descriptor](http://qr-platba.cz) which is going to be de-facto standard for QR payments on mobile devices in Czech Republic. If you're interested in full specification, please go to http://qr-platba.cz website.

## Installation

1. Download or clone this library
2. Go to spayd-sdk-ios folder
3. Copy **SmartPayment** directory into your project


## Usage

The basic usage of library is very simple. At first, you have to create configuration for your country or use some existing one *(right now, only Czech Republic is supported)*. 

```
#import "SmartPaymentCZ.h"

// The basic usage
NSString * yourQRCode = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*RF:7004139146*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";

SmartPaymentConfiguration * conf = [SmartPaymentCZ czechConfiguration];
SmartPaymentCZ * payment = [SmartPayment smartPaymentWithCode:yourQRCode configuration:conf];
if (!payment) {
	// well, something is wrong. You can display general warning, like "This is not QR code with payment"
} else {
	NSLog(@"Account: %@", payment.account);
	NSLog(@"Amount : %@ %@", payment.amount, payment.currencyCode);
	// ... etc
}
```

For advanced usage you can create instance of **SmartPaymentReader** class and parse code manually:

```
#import "SmartPaymentCZ.h"
#import "SmartPaymentReader.h"

// The basic usage
NSString * yourQRCode = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*RF:7004139146*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";

SmartPaymentConfiguration * conf = [SmartPaymentCZ czechConfiguration];
SmartPaymentReader * reader = [[SmartPaymentReader alloc] initWithConfiguration:conf]
SmartPaymentCZ * payment = [reader createPaymentFromCode:yourQRCode];
if (!payment) {
	// well, something is wrong. You can display general warning, like "This is not QR code with payment"
	// or inspect error in reader.error property.
}
```

# Library Features

## Already implemented features

* Parsing and full validation of SPD code
* Full IBAN validation
* Czech account number validation
* Czech model object for payment

## Missing features

* SmartPaymentWriter class is not implemented yet
* CRC32 validation
* Make easy to plug-in library for both simulator & devide platform