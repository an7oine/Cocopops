//
//  2015 Magna cum laude. PD
//

#import "DispatchTableViewController.h"

NSString *const DispatchTableViewCellReuseIdentifier = @"DispatchTableViewCellReuseIdentifier";

UITableViewCellAccessoryType const UITableViewCellAccessoryBlank = (UITableViewCellAccessoryType)32767;

#pragma mark - Styled cell classes

@implementation UITableViewCell (AutomaticHeight)
+ (CGFloat)automaticDimensionHeight
{
	return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomTV? 67.0f : 44.0f;
}
@end

@interface SubtitleStyleTableViewCell : UITableViewCell @end
@implementation SubtitleStyleTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]; }
+ (CGFloat)automaticDimensionHeight { return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomTV? 100.0f : 44.0f; }
@end

@interface Value1StyleTableViewCell : UITableViewCell @end
@implementation Value1StyleTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (! (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]))
		return nil;
	self.textLabel.numberOfLines = 0;
	self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.textLabel.textAlignment = NSTextAlignmentJustified;
	return self;
}
- (CGSize)preferredTextLabelSizeWithBoundingWidth:(CGFloat)boundingWidth
{
	NSDictionary *titleAttributes = @
	{
		NSParagraphStyleAttributeName : ({
			NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
			[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
			paragraphStyle;
		}),
		NSFontAttributeName : self.textLabel.font,
	};
	NSDictionary *detailAttributes = @
	{
		NSParagraphStyleAttributeName : ({
			NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
			[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
			paragraphStyle;
		}),
		NSFontAttributeName : self.detailTextLabel.font,
	};

	CGFloat width = boundingWidth - 30.0f;

	if (self.accessoryView)
		width -= 10.0f + self.accessoryView.bounds.size.width;
	else if (self.accessoryType != UITableViewCellAccessoryNone)
		width -= 10.0f + 20.0f;

	NSString *titleString = self.textLabel.attributedText.string ?: self.textLabel.text;
	NSString *detailString = self.detailTextLabel.attributedText.string ?: self.detailTextLabel.text;
	if (detailString)
		width -= 10.0f + [detailString boundingRectWithSize:CGSizeMake(width, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:detailAttributes context:nil].size.width;

	return [titleString boundingRectWithSize:CGSizeMake(width, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:titleAttributes context:nil].size;
}
- (void)layoutSubviews
{
	[super layoutSubviews];

	CGSize textLabelSize = [self preferredTextLabelSizeWithBoundingWidth:self.bounds.size.width];

	CGRect textLabelFrame = self.textLabel.frame;
	CGFloat delta = textLabelFrame.size.width - textLabelSize.width;
	if (delta >= 1.0f)
	{
		CGRect detailTextLabelFrame = self.detailTextLabel.frame;
		textLabelFrame.size = textLabelSize;
		detailTextLabelFrame.origin.x -= delta;
		detailTextLabelFrame.size.width += delta;
		self.textLabel.frame = textLabelFrame;
		self.detailTextLabel.frame = detailTextLabelFrame;

		self.textLabel.center = CGPointMake(self.textLabel.center.x, 0.5f * self.contentView.bounds.size.height);
		self.detailTextLabel.center = CGPointMake(self.detailTextLabel.center.x, 0.5f * self.contentView.bounds.size.height);

		[self.textLabel sizeToFit];
	}
}
@end

@interface Value2StyleTableViewCell : UITableViewCell @end
@implementation Value2StyleTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { return [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier]; }
@end


#pragma mark - Initialisation

@implementation DispatchTableViewController
{
	CGFloat _originalHeaderHeight, _originalFooterHeight;

	void (^_reentry)(void);
}

@synthesize hidesNavigationBarWhenPushed;

@synthesize titles=_titles, details=_details;
@synthesize headers=_headers, footers=_footers;
@synthesize accessoryTypes=_accessoryTypes;
@synthesize backgroundColours=_backgroundColours;
@synthesize blocks=_blocks;

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
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (! (self = [super initWithCoder:aDecoder]))
		return nil;
	[self clearContent];
	return self;
}

- (Class)cellClass
{
	switch (self.cellStyle)
	{
	case UITableViewCellStyleSubtitle: return SubtitleStyleTableViewCell.class;
	case UITableViewCellStyleValue1: return Value1StyleTableViewCell.class;
	case UITableViewCellStyleValue2: return Value2StyleTableViewCell.class;
	default: return UITableViewCell.class;
	}
}


#pragma mark - View lifetime

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.tableView registerClass:self.cellClass forCellReuseIdentifier:DispatchTableViewCellReuseIdentifier];

	_originalHeaderHeight = self.tableView.sectionHeaderHeight;
	_originalFooterHeight = self.tableView.sectionFooterHeight;
	if (self.tableView.style == UITableViewStyleGrouped)
		self.tableView.sectionHeaderHeight = self.tableView.sectionFooterHeight = 0.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (_reentry)
	{
		_reentry();
		_reentry = nil;
	}
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
	return _headers.count > section && [_titles[section] count] > 0 && [_headers[section] length] > 0? _headers[section] : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return _footers.count > section && [_titles[section] count] > 0 && [_footers[section] length] > 0? _footers[section] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat defaultRowHeight = tableView.rowHeight > 0.0f? tableView.rowHeight : [self.cellClass automaticDimensionHeight];

	if (self.cellStyle == UITableViewCellStyleValue1)
	{
		Value1StyleTableViewCell *cell = (Value1StyleTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		CGFloat height = [cell preferredTextLabelSizeWithBoundingWidth:CGRectGetWidth(tableView.bounds) > 0.0f? CGRectGetWidth(tableView.bounds) : CGRectGetWidth(UIScreen.mainScreen.bounds)].height;
		return MAX(height + 0.5f*defaultRowHeight, defaultRowHeight);
	}
	else
		return defaultRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DispatchTableViewCellReuseIdentifier];
	
	id title = _titles[indexPath.section][indexPath.row];
	if (title == NSNull.null)
		cell.textLabel.text = nil;
	else if ([title isKindOfClass:NSAttributedString.class])
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
	
	UIColor *backgroundColour = _backgroundColours[indexPath.section][indexPath.row];
    if (backgroundColour != (UIColor *)NSNull.null)
        cell.backgroundColor = backgroundColour;
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
	
	if (self.isViewLoaded)
        [self.tableView reloadData];
}

- (void)prepareSection:(NSInteger)section
{
	while (_titles.count <= section)
	{
		[_titles addObject:[NSMutableArray new]];
		[_details addObject:[NSMutableArray new]];
		[_headers addObject:@""];
		[_footers addObject:@""];
		[_accessoryTypes addObject:[NSMutableArray new]];
		[_backgroundColours addObject:[NSMutableArray new]];
		[_blocks addObject:[NSMutableArray new]];
		
		if (self.isViewLoaded)
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:_titles.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)setHeader:(NSString *)header forSection:(NSInteger)section
{
	[self prepareSection:section];
	_headers[section] = header;
	
	if (self.isViewLoaded)
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)setFooter:(NSString *)footer forSection:(NSInteger)section
{
	[self prepareSection:section];
	_footers[section] = footer;
	
	if (self.isViewLoaded)
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *))block
{
	NSAssert([title isKindOfClass:NSString.class] || [title isKindOfClass:NSAttributedString.class], @"'title' must be an instance of NSString or NSAttributedString !");
	NSAssert(! detail || [detail isKindOfClass:NSString.class] || [detail isKindOfClass:NSAttributedString.class], @"'detail' must be an instance of NSString or NSAttributedString !");
	NSAssert(! accessoryView || [accessoryView isKindOfClass:UIView.class] || [accessoryView isKindOfClass:NSNumber.class], @"'accessoryView' must be an instance of UIView or NSNumber !");

	[self prepareSection:section];

	NSInteger row = [_titles[section] count];
	[_titles[section] addObject:title ?: NSNull.null];
	[_details[section] addObject:detail ?: NSNull.null];
	[_accessoryTypes[section] addObject:accessoryView ?: NSNull.null];
	[_backgroundColours[section] addObject:backgroundColour ?: NSNull.null];
	[_blocks[section] addObject:block ?: ^(NSIndexPath *indexPath){}];
	
	if (self.isViewLoaded)
		[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:row inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	return row;
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(id)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *))block
{
	return [self addChoiceIntoSection:section withTitle:title detail:detail accessoryView:(UIView *)@( accessoryType ) backgroundColour:backgroundColour block:block];
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView backgroundColour:(UIColor *)backgroundColour nextViewController:(UIViewController * (^)(NSIndexPath *indexPath))nextViewController reentry:(void (^)(NSIndexPath *indexPath))reentry
{
	__weak typeof(self) nonretainedSelf = self;
	return [self addChoiceIntoSection:section withTitle:title detail:detail accessoryView:accessoryView backgroundColour:backgroundColour block:^(NSIndexPath *indexPath)
	{
		UIViewController *viewController = nextViewController(indexPath);
		if (viewController)
		{
			__strong typeof(nonretainedSelf) retainedSelf = nonretainedSelf;
			if (retainedSelf && reentry)
				retainedSelf->_reentry = ^{ reentry(indexPath); };
			[retainedSelf.navigationController pushViewController:viewController animated:YES];
		}
	}];
}

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour nextViewController:(UIViewController * (^)(NSIndexPath *indexPath))nextViewController reentry:(void (^)(NSIndexPath *indexPath))reentry
{
	return [self addChoiceIntoSection:section withTitle:title detail:detail accessoryView:(UIView *)@( accessoryType ) backgroundColour:backgroundColour nextViewController:nextViewController reentry:reentry];
}

- (NSInteger)moveChoiceFromSection:(NSInteger)section item:(NSInteger)item intoSection:(NSInteger)newSection
{
	[self prepareSection:newSection];

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
		if ([_titles[section] count] == 0)
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
		else
			[self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)setTitle:(id)title forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_titles[section][item] = title ?: NSNull.null;
	
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setDetail:(id)detail forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_details[section][item] = detail ?: NSNull.null;
	
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
	_accessoryTypes[section][item] = accessoryView ?: NSNull.null;
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setBackgroundColour:(UIColor *)backgroundColour forChoiceAtSection:(NSInteger)section item:(NSInteger)item
{
	_backgroundColours[section][item] = backgroundColour ?: NSNull.null;
	
	if (self.isViewLoaded)
		[self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:item inSection:section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Content size calculation
/*

XXX seems to lock thread?
 
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self willChangeValueForKey:@"preferredContentSize"];
}
- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[self didChangeValueForKey:@"preferredContentSize"];
}
*/

@synthesize preferredContentSize=_preferredContentSize;
- (CGSize)preferredContentSize
{
	if (_preferredContentSize.width > 0.0f && _preferredContentSize.height > 0.0f)
		return _preferredContentSize;

	UIFont *cellFont = [UITableViewCell new].textLabel.font; // get the font from a dummy cell (17.0f point)

	CGFloat width = 0.0f, height = 0.0f;

	CGFloat defaultRowHeight = UIDevice.currentDevice.userInterfaceIdiom==UIUserInterfaceIdiomTV? 67.0f : 44.0f;

	if (self.tableView.style == UITableViewStyleGrouped)
		height += 0.25f * defaultRowHeight;

	for (NSInteger section=0; section < self.tableView.numberOfSections; section++)
	{
		if (_headers.count > section && [_headers[section] length] > 0 && [_titles[section] count] > 0)
        {
            CGFloat textWidth = [_headers[section] sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width * 1.5f;
            width = MAX(width, textWidth);
			height += [self.tableView rectForHeaderInSection:section].size.height;
        }
		else if (self.tableView.style == UITableViewStyleGrouped && section == 0)
		{
			height += 0.25f * defaultRowHeight;
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
		else if (self.tableView.style == UITableViewStyleGrouped && section == self.tableView.numberOfSections-1)
		{
            height += 0.25f * defaultRowHeight;
		}
	}
	
	if (self.tableView.style == UITableViewStyleGrouped)
		height += 0.25f * defaultRowHeight;

#if TARGET_OS_TV
	height += cellFont.pointSize * 4.0f;
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
