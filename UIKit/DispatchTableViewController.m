//
//  2015 Magna cum laude. PD
//

#import "DispatchTableViewController.h"

@implementation DispatchTableViewController
- (instancetype)init
{
	if (! (self = [super init]))
		return nil;
	_choices = [NSMutableArray new];
	_headers = [NSMutableArray new];
	_footers = [NSMutableArray new];
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
	_blocks = [NSMutableDictionary new];
	return self;
}
- (void)loadView
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"PlainCell"];
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
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlainCell"];
	cell.textLabel.text = _choices[indexPath.section][indexPath.row];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	void (^block)(NSInteger rowIndex) = self.blocks[indexPath];
	if (block)
		block(indexPath.row);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title block:(void (^)(NSInteger row))block
{
	while (_choices.count <= section)
		[_choices addObject:[NSMutableArray new]];
	NSInteger row = [_choices[section] count];
	[_choices[section] addObject:title];
	_blocks[[NSIndexPath indexPathForRow:row inSection:section]] = block;
	return row;
}

- (CGSize)preferredContentSize
{
	return CGSizeMake(MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width), [self.tableView contentSize].height);
}

@end
