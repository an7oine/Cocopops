//
//  2017 Magna cum laude. PD
//

#import "DispatchBarButtonItem.h"

@interface DispatchBarButtonItem ()
@property (nonatomic, copy) void (^handler)(DispatchBarButtonItem *barButtonItem);
@end

@implementation DispatchBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(DispatchBarButtonItem *barButtonItem))handler
{
	if (! (self = [super initWithBarButtonSystemItem:systemItem target:self action:@selector(invokeHandler:)]))
		return nil;
	self.handler = handler;
	return self;
}
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(DispatchBarButtonItem *barButtonItem))handler
{
	if (! (self = [super initWithTitle:title style:style target:self action:@selector(invokeHandler:)]))
		return nil;
	self.handler = handler;
	return self;
}

- (IBAction)invokeHandler:(id)sender
{
	if (self.handler)
		self.handler(self);
}

@end
