//
//  2016 Magna cum laude. PD
//

#import "CollapsibleTableSectionHeaderView.h"

@implementation CollapsibleTableSectionHeaderView
{
	UILabel *_indicatorLabel;
	UITapGestureRecognizer *_tapRecogniser;
}

- (void)setIndicatorFrame
{
	CGFloat verticalOffset = (_collapsedStatus? 0.3f : -0.3f) * CGRectGetHeight(self.bounds);
	_indicatorLabel.frame = CGRectMake(CGRectGetMaxX(self.bounds)-1.6f*CGRectGetHeight(self.bounds), CGRectGetMidY(self.bounds)-0.8f*CGRectGetHeight(self.bounds) + verticalOffset, 1.6f*CGRectGetHeight(self.bounds), 1.6f*CGRectGetHeight(self.bounds));
	
	UIFontDescriptor *fontDescriptor = [_indicatorLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitCondensed];
	_indicatorLabel.font = [UIFont fontWithDescriptor:fontDescriptor size:1.6f*CGRectGetHeight(self.bounds)];
	_indicatorLabel.textColor = [UIColor colorWithWhite:0.7f alpha:0.7f];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	if (! _indicatorLabel)
		[self addSubview:_indicatorLabel = [[UILabel alloc] initWithFrame:CGRectZero]];
	[self setIndicatorFrame];
	
	if (! _tapRecogniser)
		[self addGestureRecognizer:_tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotTapGesture:)]];
}

@synthesize collapsedStatus=_collapsedStatus;
- (void)setCollapsedStatus:(BOOL)collapsedStatus
{
	_collapsedStatus = collapsedStatus;
	_indicatorLabel.text = _collapsedStatus? @"⌃" : @"⌄";
	[self setIndicatorFrame];
}

- (IBAction)gotTapGesture:(id)sender
{
	self.collapsedStatus = self.collapsedStatus ^ YES;

	[self.delegate tableView:(UITableView *)self.superview didSetCollapsedStatus:self.collapsedStatus forSectionWithIdentifier:self.identifier];
}

@end
