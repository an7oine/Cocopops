//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

// An ActionSheet triggering prescribed action blocks upon hitting buttons

@interface DispatchActionSheet : UIActionSheet

// the blocks are invoked upon receiving a matching -actionSheet:didDismissWithButtonIndex:
- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(NSInteger buttonIndex))block;
- (void)setCancelButtonBlock:(void (^)(NSInteger buttonIndex))block;
- (void)setDestructiveButtonBlock:(void (^)(NSInteger buttonIndex))block;

- (void (^)(NSInteger))blockWithButtonIndex:(NSInteger)buttonIndex;

// on iPad, one dummy button is added to offset the effect of iOS deleting one upon display
- (void)showAdjustedToDeviceWithView:(UIView *)view frame:(CGRect)frame;
- (void)showAdjustedToDeviceWithNavigationController:(UINavigationController *)navigationController;

@end
