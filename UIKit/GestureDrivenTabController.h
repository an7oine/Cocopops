//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface GestureDrivenTabController : UITabBarController

@property (nonatomic) BOOL disableAnimatedTransitions;
@property (nonatomic) BOOL disableUserInitiatedTransitions;
- (void)finishedWithAnimatedTransition;

@end
