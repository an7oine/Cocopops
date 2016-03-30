//
//  2015 Magna cum laude. PD
//

#import "DispatchTableViewController.h"

NSString *const DispatchTableViewCellReuseIdentifier = @"DispatchTableViewCellReuseIdentifier";

UITableViewCellAccessoryType const UITableViewCellAccessoryBlank = (UITableViewCellAccessoryType)32767;

#pragma mark - Styled cell classes

@interface SubtitleStyleTableViewCell : UITableViewCell @end
@implementation SubtitleStyleTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]; }
@end

@interface Value1StyleTableViewCell : UITableViewCell @end
@implementation Value1StyleTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]; }
@end

@interface Value2StyleTableViewCell : UITableViewCell @end
@implementation Value2StyleTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { return [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier]; }
@end


#pragma mark - Initialisation

@implementation DispatchTableViewController
{
	CGFloat _originalHeaderHeight, _originalFooterHeight;
}

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


#pragma mark - View lifetime

- (void)viewDidLoad
{
    [super viewDidLoad];

	Class cellClass = UITableViewCell.class;
	switch (self.cellStyle)
	{
	case UITableViewCellStyleSubtitle: cellClass = SubtitleStyleTableViewCell.class; break;
	case UITableViewCellStyleValue1: cellClass = Value1StyleTableViewCell.class; break;
	case UITableViewCellStyleValue2: cellClass = Value2StyleTableViewCell.class; break;
	default: break;
	}
	[self.tableView registerClass:cellClass forCellReuseIdentifier:DispatchTableViewCellReuseIdentifier];

	_originalHeaderHeight = self.tableView.sectionHeaderHeight;
	_originalFooterHeight = self.tableView.sectionFooterHeight;
	if (self.tableView.style == UITableViewStyleGrouped)
		self.tableView.sectionHeaderHeight = self.tableView.sectionFooterHeight = 0.0f;
}


#pragma mark - Table view dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _titles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_titles[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return _headers.count > section && [_titles[section] count] > 0? _headers[section] : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return _footers.count > section && [_titles[section] count] > 0? _footers[section] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DispatchTableViewCellReuseIdentifier];
	id title = _titles[indexPath.section][indexPath.row];
	if ([title isKindOfClass:NSAttributedString.class])
		cell.textLabel.attributedText = title;
	else
		cell.textLabel.text = title;
	id detail = _details[indexPath.section][indexPath.row];
	if (detail == NSNull.null)
		cell.detailTextLabel.text = nil;
	else if ([detail isKindOfClass:NSAttributedString.class])
		cell.detailTextLabel.attributedText = detail;
	else
		cell.detailTextLabel.text = detail;
	
	id accessory = _accessoryTypes[indexPath.section][indexPath.row];
	if ([accessory isKindOfClass:UIView.class])
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryView = accessory;
	}
	else if ([accessory isKindOfClass:NSNumber.class])
	{
		UITableViewCellAccessoryType accessoryType = [accessory integerValue];
		if (accessoryType == UITableViewCellAccessoryBlank)
		{
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = [[UIView alloc] initWithFrame:CGRectZero];
		}
		else
		{
			cell.accessoryType = accessoryType;
			cell.accessoryView = nil;
		}
	}
	else
		NSAssert(NO, @"Accessories must be either UIView objects or numbered standard accessory identifiers");
	
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


#pragma mark - Section header/footer height manipulation (in grouped style tables)

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_headers.count > section && [_headers[section] length] > 0 && [_titles[section] count] > 0)
        return _originalHeaderHeight;
    else if (self.tableView.style == UITableViewStyleGrouped)
        return _originalHeaderHeight;
    else
        return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_footers.count > section && [_footers[section] length] > 0 && [_titles[section] count] > 0)
        return _originalFooterHeight;
    else if (self.tableView.style == UITableViewStyleGrouped)
        return _originalFooterHeight;
    else
        return 0.0f;
}


#pragma mark - Public methods

- (void)clearContent
{
    _titles = [NSMutableArray new];
    _details = [NSMutableArray new];
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

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *))block
{
	NSAssert([title isKindOfClass:NSString.class] || [title isKindOfClass:NSAttributedString.class], @"'title' must be an instance of NSString or NSAttributedString !");
	NSAssert(! detail || [detail isKindOfClass:NSString.class] || [detail isKindOfClass:NSAttributedString.class], @"'detail' must be an instance of NSString or NSAttributedString !");

	while (_titles.count <= section)
	{
		[_titles addObject:[NSMutableArray new]];
		[_details addObject:[NSMutableArray new]];
		[_accessoryTypes addObject:[NSMutableArray new]];
		[_backgroundColours addObject:[NSMutableArray new]];
		[_blocks addObject:[NSMutableArray new]];
		
		if (self.isViewLoaded)
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:_titles.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	NSInteger row = [_titles[section] count];
	[_titles[section] addObject:title];
	[_details[section] addObject:detail ?: NSNull.null];
	[_accessoryTypes[section] addObject:accessoryView];
	[_backgroundColours[section] addObject:backgroundColour ?: UIColor.whiteColor];
	[_blocks[section] addObject:block ?: ^(NSIndexPath *indexPath){}];
	
	if (self.isViewLoaded)
		[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:row inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	return row;
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(id)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *))block
{
	return [self addChoiceIntoSection:section withTitle:title detail:detail accessoryView:(UIView *)@( accessoryType ) backgroundColour:backgroundColour block:block];
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *))block
{
	return [self addChoiceIntoSection:section withTitle:title detail:nil accessoryType:accessoryType backgroundColour:backgroundColour block:block];
}

- (NSInteger)moveChoiceFromSection:(NSInteger)section item:(NSInteger)item intoSection:(NSInteger)newSection
{
	while (_titles.count <= newSection)
	{
		[_titles addObject:[NSMutableArray new]];
		[_details addObject:[NSMutableArray new]];
		[_accessoryTypes addObject:[NSMutableArray new]];
		[_backgroundColours addObject:[NSMutableArray new]];
		[_blocks addObject:[NSMutableArray new]];

		if (self.isViewLoaded)
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:_titles.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	NSInteger newRow = [_titles[newSection] count] - (newSection==section? 1 : 0);
	
	id title = _titles[section][item];
	[_titles[section] removeObjectAtIndex:item];
	id detail = _details[section][item];
	[_details[section] removeObjectAtIndex:item];
	id accessoryType = _accessoryTypes[section][item];
	[_accessoryTypes[section] removeObjectAtIndex:item];
	UIColor *backgroundColour = _backgroundColours[section][item];
	[_backgroundColours[section] removeObjectAtIndex:item];
	id block = _blocks[section][item];
	[_blocks[section] removeObjectAtIndex:item];
	
	[_titles[newSection] addObject:title];
	[_details[newSection] addObject:detail];
	[_accessoryTypes[newSection] addObject:accessoryType];
	[_backgroundColours[newSection] addObject:backgroundColour];
	[_blocks[newSection] addObject:block];
	
	if (self.isViewLoaded)
		[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:newSection]];
	
	return newRow;
}

- (void)removeChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	[_titles[section] removeObjectAtIndex:item];
	[_details[section] removeObjectAtIndex:item];
	[_accessoryTypes[section] removeObjectAtIndex:item];
	[_backgroundColours[section] removeObjectAtIndex:item];
	[_blocks[section] removeObjectAtIndex:item];
	
	if (self.isViewLoaded)
	{
		[self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
		if ([_titles[section] count] == 0)
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)setTitle:(id)title forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_titles[section][item] = title;
	
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setDetail:(id)detail forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_details[section][item] = detail;
	
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_accessoryTypes[section][item] = @( accessoryType );
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setAccessoryView:(UIView *)accessoryView forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_accessoryTypes[section][item] = accessoryView;
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Content size calculation

@synthesize preferredContentSize=_preferredContentSize;
- (CGSize)preferredContentSize
{
	if (_preferredContentSize.width > 0.0f && _preferredContentSize.height > 0.0f)
		return _preferredContentSize;

	UIFont *cellFont = [UITableViewCell new].textLabel.font; // get the font from a dummy cell (17.0f point)

	CGFloat width = 0.0f, height = 0.0f;

	if (self.tableView.style == UITableViewStyleGrouped)
		height += _originalFooterHeight;

	for (NSInteger section=0; section < self.tableView.numberOfSections; section++)
	{
		if (_headers.count > section && [_headers[section] length] > 0 && [_titles[section] count] > 0)
        {
            CGFloat textWidth = [_headers[section] sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width * 1.5f;
            width = MAX(width, textWidth);
			height += [self.tableView rectForHeaderInSection:section].size.height;
        }
		else if (self.tableView.style == UITableViewStyleGrouped)
		{
			height += [self.tableView rectForHeaderInSection:section].size.height;
		}
		for (NSInteger item=0; item < [self.tableView numberOfRowsInSection:section]; item++)
		{
			id title = _titles[section][item];
			if ([title isKindOfClass:NSAttributedString.class])
				title = ((NSAttributedString *)title).string;
			id detail = _details[section][item];
			if (detail == NSNull.null)
				detail = @"";
			else if ([detail isKindOfClass:NSAttributedString.class])
				detail = ((NSAttributedString *)detail).string;
			id accessory = _accessoryTypes[section][item];
			
			CGFloat textWidth = [title sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width + [detail sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width;
			CGSize cellSize = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]].size;
			if ([accessory isKindOfClass:UIView.class])
				textWidth += [accessory frame].size.width;
			else
				textWidth += 1.5f*cellSize.height; // hack to fit in any regular accessory view
			width = MAX(width, textWidth);
			
			if ([self respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
                height += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            else
                height += cellSize.height;
		}
		if (_footers.count > section && [_footers[section] length] > 0 && [_titles[section] count] > 0)
        {
            CGFloat textWidth = [_footers[section] sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width * 1.5f;
            width = MAX(width, textWidth);
            height += [self.tableView rectForFooterInSection:section].size.height;
        }
		else if (self.tableView.style == UITableViewStyleGrouped)
		{
            height += [self.tableView rectForFooterInSection:section].size.height;
		}
	}
	
	if (self.tableView.style == UITableViewStyleGrouped)
		height += _originalHeaderHeight;

#if TARGET_OS_TV
	height += cellFont.pointSize * 2.5f;
#endif

	return CGSizeMake(width, height);
}


#pragma mark - tvOS support

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
