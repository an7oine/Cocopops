//
//  2016 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@protocol CollapsibleTableSectionHeaderDelegate <NSObject>

- (void)tableView:(UITableView *)tableView didSetCollapsedStatus:(BOOL)collapsedStatus forSectionWithIdentifier:(id)identifier;

@end

@interface CollapsibleTableSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic) BOOL collapsedStatus;
@property (nonatomic) id identifier;

@property (nonatomic, weak) id <CollapsibleTableSectionHeaderDelegate> delegate;

@end
