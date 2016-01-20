//
//  2015 Magna cum laude. PD
//

#import "InAppPurchaseController.h"

#import <StoreKit/StoreKit.h>

NSString * const InAppPurchaseProductDiscovery = @"InAppPurchaseProductDiscovery";
NSString * const InAppPurchaseProductPurchased = @"InAppPurchaseProductPurchased";

@interface InAppPurchaseController () <SKPaymentTransactionObserver, SKProductsRequestDelegate> @end

@implementation InAppPurchaseController
{
	NSMutableDictionary *_availableProducts;
	NSMutableSet *_purchasedProductIdentifiers;

	SKProductsRequest *_request;
}

@synthesize availableProducts=_availableProducts, purchasedProductIdentifiers=_purchasedProductIdentifiers;

static InAppPurchaseController *_sharedController;

+ (void)initialize
{
	static dispatch_once_t once;
	dispatch_once(&once, ^{ _sharedController = [[self alloc] init]; });
}

+ (instancetype)sharedController { return _sharedController; }

- (instancetype)init
{
	if (! (self = [super init]))
		return nil;

	_availableProducts = [NSMutableDictionary new];
	_purchasedProductIdentifiers = [NSMutableSet new];

	if (SKPaymentQueue.canMakePayments)
	{
		NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:[NSBundle.mainBundle URLForResource:ITEM_CATALOGUE withExtension:@"plist"]];
		_request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
		_request.delegate = self;
		[_request start];
		NSLog(@"%@ : product request started", NSStringFromClass(self.class));
	}

	[SKPaymentQueue.defaultQueue addTransactionObserver:self];

	return self;
}


#pragma mark - Fetching and making purchases

- (void)purchaseProduct:(id)product
{
	SKPayment *payment = [SKMutablePayment paymentWithProduct:product];
	[SKPaymentQueue.defaultQueue addPayment:payment];
}

- (void)restorePurchases
{
	[SKPaymentQueue.defaultQueue restoreCompletedTransactions];
}

- (void)markPurchasedProductWithIdentifier:(NSString *)identifier
{
	[_purchasedProductIdentifiers addObject:identifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseProductPurchased object:self userInfo:@{ @"productIdentifier" : identifier, @"product" : _availableProducts[identifier] ?: NSNull.null }];
}


#pragma mark - protocol SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
		switch (transaction.transactionState)
		{

			case SKPaymentTransactionStatePurchasing:
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
			case SKPaymentTransactionStateDeferred:
#endif
#if ! TARGET_OS_TV
				[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
				break;

			case SKPaymentTransactionStateFailed:
#if ! TARGET_OS_TV
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
				NSLog(@"Failed transaction: %@ (%@)", transaction, @(transaction.transactionState));
				[queue finishTransaction:transaction];
				break;

			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
			{
#if ! TARGET_OS_TV
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
				NSString *productIdentifier = transaction.payment.productIdentifier;
				SKProduct *product = _availableProducts[productIdentifier];

				if (productIdentifier)
				{
					[_purchasedProductIdentifiers addObject:productIdentifier];
					[[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseProductPurchased object:self userInfo:@{ @"productIdentifier" : productIdentifier, @"product" : product ?: NSNull.null }];
				}

				[queue finishTransaction:transaction];
				break;
			}

			default:
				// For debugging
				NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
				break;
		}
}


#pragma mark - protocol SKProductsResponseDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	_request = nil;
	NSLog(@"%@ : product request finished", NSStringFromClass(self.class));
	for (SKProduct *product in response.products)
	{
		_availableProducts[product.productIdentifier] = product;
		[[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseProductDiscovery object:self userInfo:@{ @"productIdentifier" : product.productIdentifier, @"product" : product }];
	}
}

@end
