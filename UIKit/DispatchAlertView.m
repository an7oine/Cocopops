//
//  2015 Magna cum laude. PD
//

#import "DispatchAlertView.h"

@interface DispatchAlertDelegate : NSObject <UIAlertViewDelegate>
@property (nonatomic, weak) id <UIAlertViewDelegate> clientDelegate;
@property (nonatomic, readonly) NSMutableDictionary *blockDictionary;
@end
@implementation DispatchAlertDelegate
@synthesize blockDictionary=_blockDictionary;
- (NSMutableDictionary *)blockDictionary
{
	return _blockDictionary ?: (_blockDictionary = [NSMutableDictionary new]);
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	void (^block)(NSInteger buttonIndex) = self.blockDictionary[@( buttonIndex )];
	if (block)
		block(buttonIndex);
	[self.clientDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [super respondsToSelector:aSelector] || [self.clientDelegate respondsToSelector:aSelector];
}
- (id)forwardingTargetForSelector:(SEL)aSelector { return self.clientDelegate; }
@end

@implementation DispatchAlertView
{
	DispatchAlertDelegate *_dispatchAlertDelegate;
}


#pragma mark - Delegate chaining

- (DispatchAlertDelegate *)dispatchAlertDelegate
{
	if (_dispatchAlertDelegate)
		return _dispatchAlertDelegate;
	_dispatchAlertDelegate = [[DispatchAlertDelegate alloc] init];
	[super setDelegate:_dispatchAlertDelegate];
	return _dispatchAlertDelegate;
}

- (id<UIAlertViewDelegate>)delegate { return self.dispatchAlertDelegate; }
- (void)setDelegate:(id<UIAlertViewDelegate>)delegate
{
	self.dispatchAlertDelegate.clientDelegate = delegate;
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block
{
	NSInteger index = [super addButtonWithTitle:title];
	self.dispatchAlertDelegate.blockDictionary[@( index )] = block;
	return index;
}

- (void (^)(NSInteger))blockWithButtonIndex:(NSInteger)buttonIndex
{
	return self.dispatchAlertDelegate.blockDictionary[@( buttonIndex )];
}

@end
