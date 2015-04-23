//
//  2015 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

#define ITEM_CATALOGUE @"InAppPurchases" // a plist file in NSBundle.mainBundle, where the catalogue of available items will be read at runtime

extern NSString * const InAppPurchaseProductDiscovery; // listen to get notified of new discovered IAP items
extern NSString * const InAppPurchaseProductPurchased; // listen to get notified of new purchased IAP items

@interface InAppPurchaseController : NSObject

@property (nonatomic, readonly) NSDictionary *availableProducts; // opaque (SKProduct) product objects keyed by identifier
@property (nonatomic, readonly) NSSet *purchasedProductIdentifiers;

+ (instancetype)sharedController;

- (void)purchaseProduct:(id)product;
- (void)restorePurchases;
- (void)markPurchasedProductWithIdentifier:(NSString *)identifier; // mark the given item as already purchased (as determined by your persistence logic)

@end
