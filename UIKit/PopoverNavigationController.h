//
//  2016 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

/**
A Navigation Controller optimised for displaying navigable content inside a popover
 */
@interface PopoverNavigationController : UINavigationController

@property (nonatomic) CGFloat minimumWidth;

@end

/**
An informal protocol for querying View Controllers whether they want their navigation item hidden
 */
@interface UIViewController ()

@property (nonatomic) BOOL hidesNavigationBarWhenPushed; // default NO
@property (nonatomic) BOOL hidesToolbarWhenPushed; // default YES

@end
