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
@property (nonatomic, readonly) NSMutableDictionary *blocks;

- (void)clearContent;
- (void)setHeader:(NSString *)header forSection:(NSInteger)section;
- (void)setFooter:(NSString *)footer forSection:(NSInteger)section;
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSInteger row))block;

@end
