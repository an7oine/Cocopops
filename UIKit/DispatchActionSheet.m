//
//  2014 Magna cum laude. PD
//

#import "DispatchActionSheet.h"

// Delegate class for intercepting messages sent by a UIActionSheet to its (client-supplied) delegate
// specifically, intercept any call to -actionSheet:didDismissWithButtonIndex:, act upon it, then pass it on
// any other messages, and queries for available selectors, are forwarded as-is to the client-delegate
@interface DispatchActionDelegate : NSObject <UIActionSheetDelegate>
@property (nonatomic, weak) id <UIActionSheetDelegate> clientDelegate;
@property (nonatomic, readonly) NSMutableDictionary *blockDictionary;
@end
@implementation DispatchActionDelegate
@synthesize blockDictionary=_blockDictionary;
- (NSMutableDictionary *)blockDictionary
{
    return _blockDictionary ?: (_blockDictionary = [NSMutableDictionary new]);
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    void (^block)(NSInteger buttonIndex) = self.blockDictionary[@( buttonIndex )];
    if (block)
        block(buttonIndex);
    [self.clientDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [self.clientDelegate respondsToSelector:aSelector];
}
- (id)forwardingTargetForSelector:(SEL)aSelector { return self.clientDelegate; }
@end

@implementation DispatchActionSheet
{
    DispatchActionDelegate *_dispatchActionDelegate;
}


#pragma mark - Delegate chaining

- (DispatchActionDelegate *)dispatchActionDelegate
{
    if (_dispatchActionDelegate)
        return _dispatchActionDelegate;
    _dispatchActionDelegate = [[DispatchActionDelegate alloc] init];
    [super setDelegate:_dispatchActionDelegate];
    return _dispatchActionDelegate;
}

- (id<UIActionSheetDelegate>)delegate { return self.dispatchActionDelegate; }
- (void)setDelegate:(id<UIActionSheetDelegate>)delegate
{
    self.dispatchActionDelegate.clientDelegate = delegate;
}


#pragma mark - Public methods: buttons with blocks

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block
{
    NSInteger index = [super addButtonWithTitle:title];
    self.dispatchActionDelegate.blockDictionary[@( index )] = block;
    return index;
}

- (void)setCancelButtonBlock:(void (^)(NSInteger))block
{
    self.dispatchActionDelegate.blockDictionary[@( self.cancelButtonIndex )] = block;
}

- (void)setDestructiveButtonBlock:(void (^)(NSInteger))block
{
    self.dispatchActionDelegate.blockDictionary[@( self.destructiveButtonIndex )] = block;
}

- (void (^)(NSInteger))blockWithButtonIndex:(NSInteger)buttonIndex
{
	return self.dispatchActionDelegate.blockDictionary[@( buttonIndex )];
}


#pragma mark - Public methods: iPad workarounds

- (void)showAdjustedToDeviceWithView:(UIView *)view frame:(CGRect)frame
{
	//    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) // obsolete since iOS 8?
	//        [self addButtonWithTitle:@"-"]; // dummy iPad button

    [self showInView:view];
}

- (void)showAdjustedToDeviceWithNavigationController:(UINavigationController *)navigationController
{
	//	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) // obsolete since iOS 8?
	//		[self addButtonWithTitle:@"-"]; // dummy iPad button

    [self showInView:navigationController.toolbar];
}

@end
