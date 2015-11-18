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
	_choices = [NSMutableArray new];
	_headers = [NSMutableArray new];
	_footers = [NSMutableArray new];
	_accessoryTypes = [NSMutableArray new];
	_backgroundColours = [NSMutableArray new];
	_blocks = [NSMutableDictionary new];
	return self;
}
- (instancetype)initWithStyle:(UITableViewStyle)style
{
	if (! (self = [super initWithStyle:style]))
		return nil;
	_choices = [NSMutableArray new];
	_headers = [NSMutableArray new];
	_footers = [NSMutableArray new];
	_accessoryTypes = [NSMutableArray new];
	_backgroundColours = [NSMutableArray new];
	_blocks = [NSMutableDictionary new];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return _choices.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [_choices[section] count]; }
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { return _headers.count > section? _headers[section] : nil; }
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section { return _footers.count > section? _footers[section] : nil; }
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
	void (^block)(NSInteger rowIndex) = self.blocks[indexPath];
	if (block)
		block(indexPath.row);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)clearContent
{
    _choices = [NSMutableArray new];
    _headers = [NSMutableArray new];
    _footers = [NSMutableArray new];
    _accessoryTypes = [NSMutableArray new];
    _backgroundColours = [NSMutableArray new];
    _blocks = [NSMutableDictionary new];
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

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(id)title accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSInteger row))block
{
	NSAssert([title isKindOfClass:NSString.class] || [title isKindOfClass:NSAttributedString.class], @"'title' must be an instance of NSString or NSAttributedString !");

	while (_choices.count <= section)
	{
		[_choices addObject:[NSMutableArray new]];
		[_accessoryTypes addObject:[NSMutableArray new]];
		[_backgroundColours addObject:[NSMutableArray new]];
	}
	NSInteger row = [_choices[section] count];
	[_choices[section] addObject:title];
	[_accessoryTypes[section] addObject:@( accessoryType )];
	[_backgroundColours[section] addObject:backgroundColour ?: UIColor.whiteColor];
	_blocks[[NSIndexPath indexPathForRow:row inSection:section]] = block;
	return row;
}

- (CGSize)preferredContentSize
{
	UIFont *cellFont = [UITableViewCell new].textLabel.font; // get the font from a dummy cell (17.0f point)

	CGFloat width = 0.0f, height = 0.0f;
	for (NSInteger section=0; section < self.tableView.numberOfSections; section++)
	{
		if (_headers.count > section && [_headers[section] length] > 0)
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
		if (_footers.count > section && [_footers[section] length] > 0)
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
