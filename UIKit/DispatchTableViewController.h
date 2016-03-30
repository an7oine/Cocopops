//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

/**
The reuse identifier used when dequeuing dispatch cells; you can register a custom subclass or NIB, if needed
 */
extern NSString *const DispatchTableViewCellReuseIdentifier;

/**
An additional cell accessory style, resulting in a blank space the size of a regular built-in accessory
 */
extern UITableViewCellAccessoryType const UITableViewCellAccessoryBlank;

@interface DispatchTableViewController : UITableViewController

@property (nonatomic) UITableViewCellStyle cellStyle;

@property (nonatomic) NSMutableArray *titles, *details;
@property (nonatomic) NSMutableArray *headers, *footers;
@property (nonatomic) NSMutableArray *accessoryTypes;
@property (nonatomic) NSMutableArray *backgroundColours;
@property (nonatomic) NSMutableArray *blocks;

@property (nonatomic) BOOL hidesNavigationBarWhenVisible;

- (void)clearContent;
- (void)setHeader:(NSString *)header forSection:(NSInteger)section;
- (void)setFooter:(NSString *)footer forSection:(NSInteger)section;

- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block;
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block;
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block;

- (NSInteger)moveChoiceFromSection:(NSInteger)section item:(NSInteger)item intoSection:(NSInteger)newSection;
- (void)removeChoiceAtSection:(NSInteger)section item:(NSInteger)item;

- (void)setTitle:(id)title forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
- (void)setDetail:(id)detail forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
- (void)setAccessoryView:(UIView *)accessoryView forChoiceAtSection:(NSInteger)section item:(NSInteger)item;

@end
