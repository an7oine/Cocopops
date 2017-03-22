//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

/**
 * The reuse identifier used when dequeuing dispatch cells; you can register a custom subclass or NIB, if needed
 */
extern NSString *const DispatchTableViewCellReuseIdentifier;

/**
 * An additional cell accessory style, resulting in a blank space the size of a regular built-in accessory
 */
extern UITableViewCellAccessoryType const UITableViewCellAccessoryBlank;

@interface DispatchTableViewController : UITableViewController

/**
 * The style of cell used for all rows in the table
 */
@property (nonatomic) UITableViewCellStyle cellStyle;

/**
 * Set to \c YES to hide the navigation bar on this (first) VC
 */
@property (nonatomic) BOOL hidesNavigationBarWhenPushed;

/**
 * Remove all existing sections from the table
 */
- (void)clearContent;

/**
 * Assign a header string to a specific section
 */
- (void)setHeader:(NSString *)header forSection:(NSInteger)section;
/**
 * Assign a footer string to a specific section
 */
- (void)setFooter:(NSString *)footer forSection:(NSInteger)section;

/**
 * Add a single row with the given title, detail, accessory type, colour; invoke \c block when tapped
 */
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block;
/**
 * Add a single row with the given title, detail, accessory view, colour; invoke \c block when tapped
 */
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView backgroundColour:(UIColor *)backgroundColour block:(void (^)(NSIndexPath *indexPath))block;

/**
 * Add a single row with the given title, detail, accessory view, colour; invoke and push \c nextViewController() when tapped; invoke \c reentry upon re-entry from that VC
 */
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView backgroundColour:(UIColor *)backgroundColour nextViewController:(UIViewController * (^)(NSIndexPath *indexPath))nextViewController reentry:(void (^)(NSIndexPath *indexPath))reentry;
/**
 * Add a single row with the given title, detail, accessory type, colour; invoke and push \c nextViewController() when tapped; invoke \c reentry upon re-entry from that VC
 */
- (NSInteger)addChoiceIntoSection:(NSInteger)section withTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType backgroundColour:(UIColor *)backgroundColour nextViewController:(UIViewController * (^)(NSIndexPath *indexPath))nextViewController reentry:(void (^)(NSIndexPath *indexPath))reentry;

/**
 * Move an existing row to the end of another (or current) section
 */
- (NSInteger)moveChoiceFromSection:(NSInteger)section item:(NSInteger)item intoSection:(NSInteger)newSection;
/**
 * Remove an existing row
 */
- (void)removeChoiceAtSection:(NSInteger)section item:(NSInteger)item;

/**
 * Assign a title for an existing row
 */
- (void)setTitle:(id)title forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
/**
 * Assign a detail for an existing row
 */
- (void)setDetail:(id)detail forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
/**
 * Assign an accessory type for an existing row
 */
- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
/**
 * Assign an accessory view for an existing row
 */
- (void)setAccessoryView:(UIView *)accessoryView forChoiceAtSection:(NSInteger)section item:(NSInteger)item;
/**
 * Assign a background colour for an existing row
 */
- (void)setBackgroundColour:(UIColor *)backgroundColour forChoiceAtSection:(NSInteger)section item:(NSInteger)item;

@property (nonatomic) NSMutableArray *titles, *details;
@property (nonatomic) NSMutableArray *headers, *footers;
@property (nonatomic) NSMutableArray *accessoryTypes;
@property (nonatomic) NSMutableArray *backgroundColours;
@property (nonatomic) NSMutableArray *blocks;

@end
