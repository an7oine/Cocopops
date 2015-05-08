//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface UIPopoverController (UniversalSupport)

// create and return a native instance if available (iPad), and a custom subclass instance otherwise (iPhone)
+ (UIPopoverController *)popoverControllerWithContentViewController:(UIViewController *)contentViewController;

@end
