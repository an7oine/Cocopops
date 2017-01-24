//
//  2017 Magna cum laude. PD
//

#import "UICollectionView+SupplementaryTracking.h"

#import "NSObject+AddSyntheticProperty.h"
#import "NSObject+SwizzleMethods.h"

ADD_SYNTHETIC_PROPERTY_TO_CLASS(UICollectionView, PACKED_ARG(NSMutableDictionary<NSString *, NSMapTable<NSIndexPath *, UICollectionReusableView *> *> *), supplementaryViewsByKindIndexPath_iOS8, setSupplementaryViewsByKindIndexPath_iOS8, RETAIN_NONATOMIC)

@implementation UICollectionView (SupplementaryTracking_iOS8)

- (UICollectionReusableView *)dequeueReusableSupplementaryViewOfKind_iOS8:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *supplementaryViewsByKindIndexPath = self.supplementaryViewsByKindIndexPath_iOS8;
	if (! supplementaryViewsByKindIndexPath)
		supplementaryViewsByKindIndexPath = self.supplementaryViewsByKindIndexPath_iOS8 = [NSMutableDictionary new];
	
	NSMapTable *mapTable = supplementaryViewsByKindIndexPath[elementKind];
	if (! mapTable)
		mapTable = supplementaryViewsByKindIndexPath[elementKind] = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];

	// retrieve from the original implementation, then keep a weak reference
	UICollectionReusableView *view = [self dequeueReusableSupplementaryViewOfKind_iOS8:elementKind withReuseIdentifier:identifier forIndexPath:indexPath];
	[mapTable setObject:view forKey:indexPath];
	return view;
}

- (UICollectionReusableView *)supplementaryViewForElementKind_iOS8:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
	return [self.supplementaryViewsByKindIndexPath_iOS8[elementKind] objectForKey:indexPath];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleSupplementaryElementsOfKind_iOS8:(NSString *)elementKind
{
	return [self.supplementaryViewsByKindIndexPath_iOS8[elementKind] keyEnumerator].allObjects;
}

- (NSArray<UICollectionReusableView *> *)visibleSupplementaryViewsOfKind_iOS8:(NSString *)elementKind
{
	return [self.supplementaryViewsByKindIndexPath_iOS8[elementKind] objectEnumerator].allObjects;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		// this functionality will be already implemented on iOS 9.0+ (make a runtime check)
		if (! [self instancesRespondToSelector:@selector(supplementaryViewForElementKind:atIndexPath:)])
		{
			// replace the original implementation
			[self exchangeInstanceImplementationsWithSelector:@selector(dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:) andSelector:@selector(dequeueReusableSupplementaryViewOfKind_iOS8:withReuseIdentifier:forIndexPath:)];
			
			// install a new implementation
			[self exchangeInstanceImplementationsWithSelector:@selector(supplementaryViewForElementKind:atIndexPath:) andSelector:@selector(supplementaryViewForElementKind_iOS8:atIndexPath:)];
			[self exchangeInstanceImplementationsWithSelector:@selector(indexPathsForVisibleSupplementaryElementsOfKind:) andSelector:@selector(indexPathsForVisibleSupplementaryElementsOfKind_iOS8:)];
			[self exchangeInstanceImplementationsWithSelector:@selector(visibleSupplementaryViewsOfKind:) andSelector:@selector(visibleSupplementaryViewsOfKind_iOS8:)];
		}
	});
}

@end
