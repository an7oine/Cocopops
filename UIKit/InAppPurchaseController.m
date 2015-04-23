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
		SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
		request.delegate = self;
		[request start];
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
			case SKPaymentTransactionStateDeferred:
				[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
				break;

			case SKPaymentTransactionStateFailed:
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
				NSLog(@"Failed transaction: %@ (%@)", transaction, @(transaction.transactionState));
				[queue finishTransaction:transaction];
				break;

			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
			{
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
				NSString *productIdentifier = transaction.payment.productIdentifier;
				[queue finishTransaction:transaction];

				SKProduct *product = _availableProducts[productIdentifier];
				[_purchasedProductIdentifiers addObject:productIdentifier];
				[[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseProductPurchased object:self userInfo:@{ @"productIdentifier" : productIdentifier, @"product" : product }];
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
	for (SKProduct *product in response.products)
	{
		_availableProducts[product.productIdentifier] = product;
		[[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseProductDiscovery object:self userInfo:@{ @"productIdentifier" : product.productIdentifier, @"product" : product }];
	}
}

@end
