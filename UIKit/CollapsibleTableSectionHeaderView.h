//
//  2016 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@protocol CollapsibleTableSectionHeaderDelegate <NSObject>

- (BOOL)tableView:(UITableView *)tableView collapsedStatusForSectionWithIdentifier:(id)identifier;
- (void)tableView:(UITableView *)tableView setCollapsedStatus:(BOOL)collapsedStatus forSectionWithIdentifier:(id)identifier;

@end

@interface CollapsibleTableSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic) id identifier;

@property (nonatomic, weak) id <CollapsibleTableSectionHeaderDelegate> delegate;

@end
