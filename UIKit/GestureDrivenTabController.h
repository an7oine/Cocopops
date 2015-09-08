//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@protocol GestureDrivenTabControllerDelegate <UITabBarControllerDelegate>
@optional
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldAcceptUserSelectedViewController:(UIViewController *)viewController;
@end

@interface GestureDrivenTabController : UITabBarController
@property (nonatomic) CGFloat transitionDuration;
@end
