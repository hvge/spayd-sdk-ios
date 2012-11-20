# Smart Payment Descriptor for iOS

The **spayd-sdk-ios** project is a full iOS implementation of [Smart Payment Descriptor](http://qr-platba.cz) which is a standard for QR code payments on mobile devices in Czech Republic. If you're interested in full specification, please go to http://qr-platba.cz website.

## Library Features

### License

The library is licensed under [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). It means that it can be freely used for non-commercial and also for commercial projects. For more information look for full license agreement.

The SPD standard also is patent free.

### Already implemented features

* Parsing and full validation of SPD code
* Full IBAN validation
* Czech account number validation
* Czech model object for payment

### Missing features

* SmartPaymentWriter class is not implemented yet
* CRC32 validation
* Make easy to plug-in library for both simulator & devide platform


## Installation & Usage

### Installation

1. Download or clone this library
2. Go to spayd-sdk-ios folder
3. Copy **SmartPayment** directory into your project

### Usage

The basic usage is very simple:

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
	// well, something is wrong. In this case you can inspect error in reader.error property.
}
```

### Note about configurations

The **SmartPaymentConfiguration** class holds information typical for domestic payments, like default currency code and time zone, valid for your country. The default currency code is used only when QR code doesn't contain CC attribute. The configuration also keeps configuration for **SmartPayment** and **SmartPaymentAccount** model classes.
