//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface DispatchAlertView : UIAlertView

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block;
- (void (^)(NSInteger))blockWithButtonIndex:(NSInteger)buttonIndex;

@end
