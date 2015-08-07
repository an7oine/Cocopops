//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface DispatchAlertView : UIAlertView

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block;
- (void)setCancelButtonBlock:(void (^)(NSInteger buttonIndex))block;
- (void (^)(NSInteger))blockWithButtonIndex:(NSInteger)buttonIndex;

- (void)dismissWithCancelButton; // invokes code assigned to the "Cancel" button
- (void)dismissWithFirstOtherButton; // invokes code assigned to the "Accept" button

@end
