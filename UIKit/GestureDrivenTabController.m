//
//  2015 Magna cum laude. PD
//

#import "GestureDrivenTabController.h"

@interface TabSwitchAnimator : NSObject <UIViewControllerAnimatedTransitioning> @end
@implementation TabSwitchAnimator
{
    BOOL _fromLeft;
    void (^_completionBlock)(void);
}

+ (instancetype)animatorForSwitchFromTheLeft:(BOOL)fromLeft completionBlock:(void (^)(void))completionBlock
{
    TabSwitchAnimator *animator = [self new];
    animator->_fromLeft = fromLeft;
    animator->_completionBlock = completionBlock;
    return animator;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toView aboveSubview:fromView];
    
    CGRect endFrame = [transitionContext finalFrameForViewController:toVC];
    CGRect beginFrame = CGRectOffset(endFrame, _fromLeft? -endFrame.size.width : endFrame.size.width, 0.0f);
    
    toView.frame = beginFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         toView.frame = endFrame;
     } completion:^(BOOL finished)
     {
         [fromView removeFromSuperview];
         [transitionContext completeTransition:YES];
         if (_completionBlock)
             _completionBlock();
     }];
}

@end

@interface GestureDrivenTabController () <UIGestureRecognizerDelegate, UITabBarControllerDelegate> @end

@implementation GestureDrivenTabController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBar.hidden = YES;
    
    UIScreenEdgePanGestureRecognizer *leftEdgeRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gotLeftEdgePanGesture:)];
    leftEdgeRecogniser.edges = UIRectEdgeLeft;
    leftEdgeRecogniser.delegate = self;
    [self.view addGestureRecognizer:leftEdgeRecogniser];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gotRightEdgePanGesture:)];
    rightEdgeRecogniser.edges = UIRectEdgeRight;
    rightEdgeRecogniser.delegate = self;
    [self.view addGestureRecognizer:rightEdgeRecogniser];
    
    self.delegate = self;
}

// switch to prev/next display, but only once per edge-pan gesture
- (IBAction)gotLeftEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan && ! self.disableUserInitiatedTransitions && self.selectedIndex > 0)
        [self setSelectedIndex:self.selectedIndex-1];
}
- (IBAction)gotRightEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan && ! self.disableUserInitiatedTransitions && self.selectedIndex < self.viewControllers.count-1)
        [self setSelectedIndex:self.selectedIndex+1];
}

// allow swipe gestures to combine with any applicable content gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// animate tab switches by way of sliding new tabs on top of the old
- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (self.disableAnimatedTransitions)
        return nil;
    else
        return [TabSwitchAnimator animatorForSwitchFromTheLeft:[self.viewControllers indexOfObject:fromVC] > [self.viewControllers indexOfObject:toVC] completionBlock:^{ [self finishedWithAnimatedTransition]; }];
}

- (void)finishedWithAnimatedTransition { }

@end
