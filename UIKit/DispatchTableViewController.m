//
//  2015 Magna cum laude. PD
//

#import "DispatchTableViewController.h"

NSString *const DispatchTableViewCellReuseIdentifier = @"DispatchTableViewCellReuseIdentifier";

@implementation DispatchTableViewController
- (instancetype)init
{
	if (! (self = [super init]))
		return nil;
	[self clearContent];
	return self;
}
- (instancetype)initWithStyle:(UITableViewStyle)style
{
	if (! (self = [super initWithStyle:style]))
		return nil;
	[self clearContent];
	return self;
}
- (void)loadView
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:DispatchTableViewCellReuseIdentifier];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.view = self.tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _choices.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_choices[section] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return _headers.count > section && [_choices[section] count] > 0? _headers[section] : nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return _footers.count > section && [_choices[section] count] > 0? _footers[section] : nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DispatchTableViewCellReuseIdentifier];
	id text = _choices[indexPath.section][indexPath.row];
	if ([text isKindOfClass:NSAttributedString.class])
		cell.textLabel.attributedText = text;
	else
		cell.textLabel.text = text;
	cell.accessoryType = [_accessoryTypes[indexPath.section][indexPath.row] integerValue];
	cell.backgroundColor = _backgroundColours[indexPath.section][indexPath.row];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	void (^block)(NSIndexPath *indexPath) = self.blocks[indexPath.section][indexPath.item];
	if (block)
		block(indexPath);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)clearContent
{
    _choices = [NSMutableArray new];
    _headers = [NSMutableArray new];
    _footers = [NSMutableArray new];
    _accessoryTypes = [NSMutableArray new];
    _backgroundColours = [NSMutableArray new];
    _blocks = [NSMutableArray new];
}

- (void)setHeader:(NSString *)header forSection:(NSInteger)section
{
	while (_headers.count < section)
		[_headers addObject:@""];
	if (_headers.count == section)
		[_headers addObject:header];
	else
		_headers[section] = header;
}
- (void)setFooter:(NSString *)footer forSection:(NSInteger)section
{
	while (_footers.count < section)
		[_footers addObject:@""];
	if (_footers.count == section)
		[_footers addObject:footer];
	else
		_footers[section] = footer;
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(id)title accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block
{
	NSAssert([title isKindOfClass:NSString.class] || [title isKindOfClass:NSAttributedString.class], @"'title' must be an instance of NSString or NSAttributedString !");

	while (_choices.count <= section)
	{
		[_choices addObject:[NSMutableArray new]];
		[_accessoryTypes addObject:[NSMutableArray new]];
		[_backgroundColours addObject:[NSMutableArray new]];
		[_blocks addObject:[NSMutableArray new]];
		
		if (self.isViewLoaded)
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:_choices.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	NSInteger row = [_choices[section] count];
	[_choices[section] addObject:title];
	[_accessoryTypes[section] addObject:@( accessoryType )];
	[_backgroundColours[section] addObject:backgroundColour ?: UIColor.whiteColor];
	[_blocks[section] addObject:block];
	
	if (self.isViewLoaded)
		[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:row inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	return row;
}

- (NSInteger)moveChoiceFromSection:(NSInteger)section item:(NSInteger)item intoSection:(NSInteger)newSection
{
	while (_choices.count <= newSection)
	{
		[_choices addObject:[NSMutableArray new]];
		[_accessoryTypes addObject:[NSMutableArray new]];
		[_backgroundColours addObject:[NSMutableArray new]];
		[_blocks addObject:[NSMutableArray new]];

		if (self.isViewLoaded)
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:_choices.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	NSInteger newRow = [_choices[newSection] count] - (newSection==section? 1 : 0);
	
	NSString *title = _choices[section][item];
	[_choices[section] removeObjectAtIndex:item];
	NSNumber *accessoryType = _accessoryTypes[section][item];
	[_accessoryTypes[section] removeObjectAtIndex:item];
	UIColor *backgroundColour = _backgroundColours[section][item];
	[_backgroundColours[section] removeObjectAtIndex:item];
	id block = _blocks[section][item];
	[_blocks[section] removeObjectAtIndex:item];
	
	[_choices[newSection] addObject:title];
	[_accessoryTypes[newSection] addObject:accessoryType];
	[_backgroundColours[newSection] addObject:backgroundColour];
	[_blocks[newSection] addObject:block];
	
	if (self.isViewLoaded)
		[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:newSection]];
	
	return newRow;
}

- (void)removeChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	[_choices[section] removeObjectAtIndex:item];
	[_accessoryTypes[section] removeObjectAtIndex:item];
	[_backgroundColours[section] removeObjectAtIndex:item];
	[_blocks[section] removeObjectAtIndex:item];
	
	if (self.isViewLoaded)
		[self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setTitle:(NSString *)title forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_choices[section][item] = title;
	
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@synthesize preferredContentSize=_preferredContentSize;
- (CGSize)preferredContentSize
{
	if (_preferredContentSize.width > 0.0f && _preferredContentSize.height > 0.0f)
		return _preferredContentSize;

	UIFont *cellFont = [UITableViewCell new].textLabel.font; // get the font from a dummy cell (17.0f point)

	CGFloat width = 0.0f, height = 0.0f;
	for (NSInteger section=0; section < self.tableView.numberOfSections; section++)
	{
		if (_headers.count > section && [_headers[section] length] > 0 && [_choices[section] count] > 0)
        {
            CGFloat textWidth = [_headers[section] sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width * 1.5f;
            width = MAX(width, textWidth);
			height += [self.tableView rectForHeaderInSection:section].size.height;
        }
		for (NSInteger item=0; item < [self.tableView numberOfRowsInSection:section]; item++)
		{
			NSString *text = _choices[section][item];
			if ([text isKindOfClass:NSAttributedString.class])
				text = ((NSAttributedString *)text).string;
			CGFloat textWidth = [text sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width;
			CGSize cellSize = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]].size;
			width = MAX(width, textWidth + 1.5f*cellSize.height); // hack to fit in any accessory view
			height += cellSize.height;
		}
		if (_footers.count > section && [_footers[section] length] > 0 && [_choices[section] count] > 0)
        {
            CGFloat textWidth = [_footers[section] sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width * 1.5f;
            width = MAX(width, textWidth);
            height += [self.tableView rectForFooterInSection:section].size.height;
        }
	}

#if TARGET_OS_TV
	height += cellFont.pointSize * 2.5f;
#endif

	return CGSizeMake(width, height);
}

#if TARGET_OS_TV
- (UIView *)preferredFocusedView
{
	for (NSInteger section=0; section < _accessoryTypes.count; section++)
		for (NSInteger item=0; item < [_accessoryTypes[section] count]; item++)
			if ([_accessoryTypes[section][item] integerValue] == UITableViewCellAccessoryCheckmark)
				return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
	return super.preferredFocusedView;
}
#endif

@end
