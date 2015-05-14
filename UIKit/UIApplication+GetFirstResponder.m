//
//  2015 Magna cum laude. PD
//

#import "UIApplication+GetFirstResponder.h"

@implementation UIResponder (IdentifySelfUsingBlock)
- (void)identifySelfUsingBlock:(void (^)(id firstResponder))block { block(self); }
@end

@implementation UICollectionView (IdentifySelfUsingBlock)
- (void)identifySelfUsingBlock:(void (^)(id firstResponder))block
{
	UICollectionViewCell *selectedCell = [self cellForItemAtIndexPath:self.indexPathsForSelectedItems.firstObject];
	if (selectedCell.isFirstResponder)
		block(selectedCell);
	else if (self.isFirstResponder)
		block(self);
}
@end

@implementation UIApplication (GetFirstResponder)

- (UIResponder *)firstResponder
{
	__block UIResponder *result = nil;
	[self sendAction:@selector(identifySelfUsingBlock:) to:nil from:^(id firstResponder){ result = firstResponder; } forEvent:nil];
	return result;
}

@end
