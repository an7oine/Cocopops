//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

extern NSString *const DispatchTableViewCellReuseIdentifier; // use this to register a custom subclass or NIB for the dispatch cells

@interface DispatchTableViewController : UITableViewController

@property (nonatomic) NSMutableArray *choices;
@property (nonatomic) NSMutableArray *headers, *footers;
@property (nonatomic) NSMutableArray *accessoryTypes;
@property (nonatomic) NSMutableArray *backgroundColours;
@property (nonatomic) NSMutableArray *blocks;

@property (nonatomic) BOOL hidesNavigationBarWhenVisible;

- (void)clearContent;
- (void)setHeader:(NSString *)header forSection:(NSInteger)section;
- (void)setFooter:(NSString *)footer forSection:(NSInteger)section;

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(id)title accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block;
- (NSInteger)moveChoiceFromSection:(NSInteger)section item:(NSInteger)item intoSection:(NSInteger)newSection;
- (void)removeChoiceAtSection:(NSInteger)section item:(NSInteger)item;

- (void)setTitle:(NSString *)title forChoiceAtSection:(NSInteger)section item:(NSInteger)item;

@end
