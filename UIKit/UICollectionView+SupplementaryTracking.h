//
//  2017 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface UICollectionView (SupplementaryTracking)

#ifndef __IPHONE_9_0

// already defined on iOS 9.0+ (compile-time check)

- (UICollectionReusableView *)supplementaryViewForElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (NSArray<NSIndexPath *> *)indexPathsForVisibleSupplementaryElementsOfKind:(NSString *)elementKind;
- (NSArray<UICollectionReusableView *> *)visibleSupplementaryViewsOfKind:(NSString *)elementKind;

#endif

@end
