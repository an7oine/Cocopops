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

- (CGSize)inputViewSize
{
	__block CGSize result = CGSizeZero;
	UIResponder *firstResponder = self.firstResponder;
	id observer = [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
		result = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	}];
	[firstResponder resignFirstResponder];
	[firstResponder becomeFirstResponder];
	[NSNotificationCenter.defaultCenter removeObserver:observer];
	return result;
}

@end
