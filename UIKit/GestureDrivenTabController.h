//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

typedef enum
{
	kTabTransitionNone = 0,			// no transition (instant tab switch)
	kTabTransitionIncomingOnTop,	// new tabs shall always appear on top of existing tabs
	kTabTransitionOutgoingOnTop,	// new tabs shall always appear below existing tabs
	kTabTransitionLeftOnTop,		// tabs on the left shall always appear on top of those on the right
	kTabTransitionRightOnTop,		// tabs on the right shall always appear on top of those on the left
	kTabTransitionSideBySide,		// as new tabs appear, the existing tabs shall slide apart from them
} gestureDrivenTabTransitionStyle_t;

typedef enum
{
	kTabGestureNone = 0,			// no gestures will be recognised
	kTabGestureEdge = 1,			// edge-swipe to switch tabs
	kTabGestureTwoFinger = 2,		// swipe sideways using two fingers to switch tabs
} gestureDrivenTabGestureType_t;

@protocol GestureDrivenTabControllerDelegate <UITabBarControllerDelegate>
@optional
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldAcceptUserSelectedViewController:(UIViewController *)viewController;
@end

@interface GestureDrivenTabController : UITabBarController
@property (nonatomic) gestureDrivenTabTransitionStyle_t transitionStyle;
@property (nonatomic) gestureDrivenTabGestureType_t gestureType;
@property (nonatomic) CGFloat transitionDuration;
@property (nonatomic, getter=isCircular) BOOL circular; // wrap around from the last to first VC and vice versa
@end
