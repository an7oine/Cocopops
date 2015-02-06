//
//  2014 Magna cum laude. PD
//

#import "InputAccessoryToolbar.h"

@implementation InputAccessoryToolbar

@synthesize content=_content;
@synthesize titleItem=_titleItem;
@synthesize prevItem=_prevItem, nextItem=_nextItem;
@synthesize clearItem=_clearItem, doneItem=_doneItem;

- (void)makeButtons
{
	NSMutableArray *items = [NSMutableArray new];

	if (_content & kToolbarTitle)
	{
		// a textual button bearing an empty string
		[items addObject:_titleItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
		// if this is not the last (only) item, add a flexible gap next
		if ((_content & ~kToolbarTitle) > kToolbarTitle)
			[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	}

	if (_content & kToolbarArrows)
	{
		// an arrow symbol pointing left
		[items addObject:_prevItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:105 target:nil action:nil]];
		// a small gap between the arrows
		[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil]];
		[items.lastObject setWidth:self.bounds.size.height / 2.0];
		// an arrow symbol pointing right
		[items addObject:_nextItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:105 target:nil action:nil]];
		// if this is not the last item, add another small gap after the arrows
		if ((_content & ~kToolbarArrows) > kToolbarArrows)
		{
			[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil]];
			[items.lastObject setWidth:self.bounds.size.height / 2.0];
		}
	}

	if (_content & kToolbarClear)
		// a textual "Cancel" button
		[items addObject:_clearItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil]];

	if (_content & kToolbarDone)
		// a textual "Done" button
		[items addObject:_doneItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil]];

	self.items = items;
}

- (instancetype)initWithFrame:(CGRect)frame content:(toolbarContent_t)content
{
	if (!(self = [super initWithFrame:frame]))
		return nil;

	_content = content;
	[self makeButtons];
    [self sizeToFit];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	return self;
}

@end
