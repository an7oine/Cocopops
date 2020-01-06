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
	_indicatorLabel.frame = CGRectMake(
        CGRectGetMaxX(self.bounds)-0.8f*CGRectGetHeight(self.bounds),
        CGRectGetMidY(self.bounds)-0.6f*CGRectGetHeight(self.bounds),
        1.6f*CGRectGetHeight(self.bounds),
        1.6f*CGRectGetHeight(self.bounds)
    );
	
	UIFontDescriptor *fontDescriptor = [_indicatorLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitExpanded];
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
	
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_indicatorLabel.text = self.collapsedStatus? @"˄" : @"˅";
	[self setIndicatorFrame];
}

- (BOOL)collapsedStatus
{
	return [self.delegate tableView:(UITableView *)self.superview collapsedStatusForSectionWithIdentifier:self.identifier];
}
- (void)setCollapsedStatus:(BOOL)collapsedStatus
{
	[self.delegate tableView:(UITableView *)self.superview setCollapsedStatus:collapsedStatus forSectionWithIdentifier:self.identifier];
	[self setNeedsLayout];
}

- (IBAction)gotTapGesture:(id)sender
{
	self.collapsedStatus = self.collapsedStatus ^ YES;
}

@end
