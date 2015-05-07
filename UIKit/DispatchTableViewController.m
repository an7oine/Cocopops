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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return _choices.count; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlainCell"];
	cell.textLabel.text = _choices[indexPath.row];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	void (^block)(NSInteger rowIndex) = self.blocks[@( indexPath.row )];
	if (block)
		block(indexPath.row);
}

- (NSInteger)addChoiceWithTitle:(NSString *)title block:(void (^)(NSInteger))block
{
	NSInteger row = _choices.count;
	[_choices addObject:title];
	_blocks[@( row )] = block;
	return row;
}

@end
