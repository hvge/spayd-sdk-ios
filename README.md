# Smart Payment Descriptor for iOS

The **SmartPayment** project is a full iOS implementation of [Smart Payment Descriptor](http://qr-platba.cz) which is a standard for QR code payments on mobile devices in Czech Republic. If you're interested in full specification, please go to http://qr-platba.cz website.

## Library Features

### License

The library is licensed under [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). It means that it can be freely used for non-commercial and also for commercial projects. For more information look for full license agreement.

The SPD standard is also patent free.

### Already implemented features

* Parsing and full validation of SPD code
* Full IBAN validation
* Czech account number validation
* Czech model object for payment

### Missing features

* SmartPaymentWriter class is not implemented yet
* CRC32 validation


## Installation & Usage

### Installation

The SmartPayment library is designed for ARC environment and minumum supported iOS version is iOS5. If your project is not ARC ready then you can use **-fobjc-arc** compiler flag to turn it on on per-file basis (look for [LLVM documentation](http://clang.llvm.org/docs/AutomaticReferenceCounting.html) for details). This code may also work well on iOS4.2.x  *(due to partial ARC support in that systems)*, but we're not supporting this operating system in MASTER branch.

#### Precompiled library

1. Go to [downloads](https://github.com/hvge/spayd-sdk-ios/downloads) and download precompiled version of library
2. Extract downloaded archive and drag & drop its content into your Xcode project
3. Check VERSION.txt if archive contains up to date version of library

#### Manual copy & setup

1. Download or clone this library
2. Go to **Sources** folder
3. Copy **SmartPayment** directory into your project
4. Add **libz** into your linker settings (libz is required for full CRC32 validation)


### Usage

The basic usage is very simple:

```
#import "SmartPaymentCZ.h"

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

NSString * yourQRCode = @"SPD*1.0*ACC:CZ5855000000001265098001*AM:480.50*CC:CZK*RF:7004139146*X-VS:1234567890*DT:20120524*MSG:PLATBA ZA ZBOZI";

SmartPaymentConfiguration * conf = [SmartPaymentCZ czechConfiguration];
SmartPaymentReader * reader = [[SmartPaymentReader alloc] initWithConfiguration:conf]
SmartPaymentCZ * payment = [reader createPaymentFromCode:yourQRCode];
if (!payment) {
	// well, something is wrong. In this case you can inspect error in reader.error property.
}
```

### Note about configurations

The **SmartPaymentConfiguration** class holds information typical for domestic payments, like default currency code and time zone, valid for your country. The default currency code is used only when QR code doesn't contain CC attribute. The configuration also keeps setup for **SmartPayment** and **SmartPaymentAccount** model classes. 

Without propper configuration you will not be able to parse DT (due date) attribute correctly and produced NSDate will not be accurate due to wrong GMT offset in the time zone. This concept works well for domestic payments but may be inaccurate for foreign bank transfers. Ask me at juraj@inmite.eu about how to solve this problem correctly.
