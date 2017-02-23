//
//  2017 Magna cum laude. PD
//

#import "DispatchBarButtonItem.h"

@interface DispatchBarButtonItem ()
@property (nonatomic, copy) void (^handler)(void);
@end

@implementation DispatchBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(void))handler
{
	if (! (self = [super initWithBarButtonSystemItem:systemItem target:self action:@selector(invokeHandler:)]))
		return nil;
	self.handler = handler;
	return self;
}
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(void))handler
{
	if (! (self = [super initWithTitle:title style:style target:self action:@selector(invokeHandler:)]))
		return nil;
	self.handler = handler;
	return self;
}

- (IBAction)invokeHandler:(id)sender
{
	if (self.handler)
		self.handler();
}

@end
