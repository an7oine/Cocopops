//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface DispatchTableViewController : UITableViewController

@property (nonatomic) NSMutableArray *choices;
@property (nonatomic, readonly) NSMutableDictionary *blocks;

- (NSInteger)addChoiceWithTitle:(NSString *)title block:(void (^)(NSInteger row))block;

@end
