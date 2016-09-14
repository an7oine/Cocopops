//
//  2016 Magna cum laude. PD
//

#import "TVPickerView.h"

#import "NSArray+CreateByBlock.h"
#import "NSArray+ReplaceObject.h"

@interface TVPickerTableViewCell : UITableViewCell @end
@implementation TVPickerTableViewCell
- (UIView *)preferredFocusedView
{
	// if focus is already within this table, permit changes in the focused cell
	if ([UIScreen.mainScreen.focusedView isDescendantOfView:self.superview.superview])
		return self;
	
	// otherwise (moving in from another part of the view hierarchy), redirect focus to the currently picked cell
	else
		return self.superview.superview.preferredFocusedView;
}
@end

@interface TVPickerView () <UITableViewDataSource, UITableViewDelegate> @end

@implementation TVPickerView
{
	NSArray<UITableView *> *_tables;
	NSArray<NSNumber *> *_selection;
}

- (void)layoutSubviews
{
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

	[super layoutSubviews];

	NSMutableArray *tables = [NSMutableArray new];
	for (NSInteger component = 0; component < self.numberOfComponents; component++)
	{
		CGRect frame = CGRectMake(0.0f, 0.0f, [self widthOfComponent:component], 0.0f);
		UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
		[tableView registerClass:TVPickerTableViewCell.class forCellReuseIdentifier:@"PickerTableViewCell"];
		tableView.dataSource = self;
		tableView.delegate = self;
		tableView.rowHeight = [self rowHeightForComponent:component];
		[tables addObject:tableView];
	}
	_tables = tables;
	
	UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:tables];
	stackView.frame = self.bounds;
	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.distribution = UIStackViewDistributionFillEqually;
	stackView.alignment = UIStackViewAlignmentFill;
	stackView.spacing = 10.0f;
	[self addSubview:stackView];
	
	[stackView layoutSubviews];
}

- (NSInteger)numberOfComponents
{
	return [self.dataSource numberOfComponentsInPickerView:self];
}
- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
	return [self.dataSource pickerView:self numberOfRowsInComponent:component];
}

- (CGFloat)widthOfComponent:(NSInteger)component
{
	if ([self.delegate respondsToSelector:@selector(pickerView:widthForComponent:)])
		return [self.delegate pickerView:self widthForComponent:component];
	else
		return 0.0f;
}

- (CGFloat)rowHeightForComponent:(NSInteger)component
{
	if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)])
		return [self.delegate pickerView:self rowHeightForComponent:component];
	else
		return UITableViewAutomaticDimension;
}

- (void)reloadAllComponents
{
	for (NSInteger component = 0; component < self.numberOfComponents; component++)
		[self reloadComponent:component];
}
- (void)reloadComponent:(NSInteger)component
{
	[_tables[component] reloadData];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
	if (! [_selection[component] isEqualToValue:@( row )])
	{
		NSMutableArray *selection = _selection.mutableCopy ?: [NSMutableArray arrayWithSize:self.numberOfComponents byBlock:^id(NSArray *priorObjects, NSUInteger idx) {
			return @0;
		}];
	
		[_tables[component] cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_selection[component] integerValue] inSection:0]].backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];

		selection[component] = @( row );
		_selection = selection;
		
		[_tables[component] cellForRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]].backgroundColor = [UIColor whiteColor];
		
		[_tables[component] setNeedsFocusUpdate];
	}
}

- (NSInteger)selectedRowInComponent:(NSInteger)component
{
	return [_selection[component] integerValue];
}


#pragma mark - UITableView dataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self numberOfRowsInComponent:[_tables indexOfObject:tableView]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickerTableViewCell"];
	NSInteger component = [_tables indexOfObject:tableView];
	if (component == NSNotFound)
	{
		cell.textLabel.text = nil;
		cell.backgroundColor = nil;
		return cell;
	}

	if ([self.delegate respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)])
		cell.textLabel.attributedText = [self.delegate pickerView:self attributedTitleForRow:indexPath.item forComponent:component];
	else if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)])
		cell.textLabel.text = [self.delegate pickerView:self titleForRow:indexPath.item forComponent:component];
	else
		cell.textLabel.text = @"";
	cell.backgroundColor = [self selectedRowInComponent:component] == indexPath.item? [UIColor whiteColor] : [UIColor colorWithWhite:0.85f alpha:1.0f];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	[self.delegate pickerViewDidFinish:self];
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView
{
	NSInteger component = [_tables indexOfObject:tableView];
	return [NSIndexPath indexPathForItem:[self selectedRowInComponent:component] inSection:0];
}

- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
	if ([context.nextFocusedView isDescendantOfView:tableView])
	{
		NSInteger component = [_tables indexOfObject:tableView];
		if ([context.previouslyFocusedView isDescendantOfView:tableView])
		{
			if (! [_selection[component] isEqualToValue:@( context.nextFocusedIndexPath.item )])
			{
				NSMutableArray *selection = _selection.mutableCopy;
				selection[component] = @( context.nextFocusedIndexPath.item );
				_selection = selection;

				[coordinator addCoordinatedAnimations:^
				{
					context.previouslyFocusedView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
					context.nextFocusedView.backgroundColor = [UIColor whiteColor];
				} completion:^
				{
					[self.delegate pickerView:self didSelectRow:context.nextFocusedIndexPath.item inComponent:component];
				}];
			}
		}
	}
}

- (UIView *)preferredFocusedView
{
	return _tables[self.preferredFocusedComponent];
}

@end
