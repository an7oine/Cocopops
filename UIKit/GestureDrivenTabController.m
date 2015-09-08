//
//  2015 Magna cum laude. PD
//

#import "GestureDrivenTabController.h"


@interface GestureDrivenTabController () <UIGestureRecognizerDelegate> @end

@implementation GestureDrivenTabController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIScreenEdgePanGestureRecognizer *leftEdgeRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gotLeftEdgePanGesture:)];
    leftEdgeRecogniser.edges = UIRectEdgeLeft;
    leftEdgeRecogniser.delegate = self;
    [self.view addGestureRecognizer:leftEdgeRecogniser];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gotRightEdgePanGesture:)];
    rightEdgeRecogniser.edges = UIRectEdgeRight;
    rightEdgeRecogniser.delegate = self;
    [self.view addGestureRecognizer:rightEdgeRecogniser];
	
	if (! self.transitionDuration)
		self.transitionDuration = 0.2f;
}

- (void)handleEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender fromTheLeft:(BOOL)fromTheLeft
{
	// get the current view hierarchy
    UIView *containerView = self.view;
    UIView *currentView = self.selectedViewController.view;

	// get the to-be-overlaid VC and have it load its view, then get that as well
	UIViewController *overlayVC = self.viewControllers[self.selectedIndex + (fromTheLeft?-1:1)];
    UIView *overlayView = overlayVC.view;

	// get the on-screen (horizontal) location and velocity of the gesture
    CGFloat touchLocation = [sender translationInView:containerView].x + (fromTheLeft? 0.0f : CGRectGetWidth(containerView.bounds));
    CGFloat touchVelocity = [sender velocityInView:containerView].x;
    
    switch (sender.state)
    {
		// ignore non-definitive touches
        case UIGestureRecognizerStatePossible:
            break;

		// when the gesture starts, present the incoming overlay view and inform its controller
        case UIGestureRecognizerStateBegan:
			[overlayVC viewWillAppear:NO];
            [containerView insertSubview:overlayView aboveSubview:currentView];
			[overlayVC viewDidAppear:NO];
            // then fall through to the 'changed' case:

		// each time the user moves their finger, adjust the overlay position accordingly
        case UIGestureRecognizerStateChanged:
            if (fromTheLeft)
                overlayView.frame = CGRectOffset(containerView.bounds, -CGRectGetWidth(containerView.bounds)+touchLocation, 0.0f);
            else
                overlayView.frame = CGRectOffset(containerView.bounds, touchLocation, 0.0f);
            break;

		// when finished, inspect the location and velocity to determine whether the user wants to switch tabs or if they changed their mind halfway through to the gesture
        case UIGestureRecognizerStateEnded:
        {
            // if the gesture in its current state of position + velocity would favour a transition, perform it
            BOOL landingLeft = touchLocation + self.transitionDuration * touchVelocity < CGRectGetMidX(currentView.bounds);
            if (fromTheLeft && ! landingLeft)
            {
				// animate a slide-in from left to right
				[UIView animateWithDuration:self.transitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
				{
					overlayView.frame = currentView.frame;
				} completion:^(BOOL finished)
				{
					[self setSelectedIndex:self.selectedIndex-1];
					[self didSelectViewControllerAtIndex:self.selectedIndex];
				}];
                break;
            }
            else if (! fromTheLeft && landingLeft)
            {
				// animate a slide-in from right to left
				[UIView animateWithDuration:self.transitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
				{
					overlayView.frame = currentView.frame;
				} completion:^(BOOL finished)
				{
					[self setSelectedIndex:self.selectedIndex+1];
					[self didSelectViewControllerAtIndex:self.selectedIndex];
				}];
                break;
            }
            // otherwise, fall through to the 'failed' case:
        }
		
		// if the gesture fails, is cancelled, or the user did not want a transition, pull back and remove the overlay view
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            // animate a slide-out back to whence the overlay came
            [UIView animateWithDuration:self.transitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^
            {
                if (fromTheLeft)
                    overlayView.frame = CGRectOffset(currentView.frame, -containerView.bounds.size.width, 0.0f);
                else
                    overlayView.frame = CGRectOffset(currentView.frame, containerView.bounds.size.width, 0.0f);
            } completion:^(BOOL finished)
            {
				[overlayVC viewWillDisappear:NO];
				[overlayView removeFromSuperview];
				[overlayVC viewDidDisappear:NO];
            }];
            break;
    }
}

// handle user gestures only if not disabled
- (IBAction)gotLeftEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
    if (self.selectedIndex > 0 && [self shouldAcceptUserSelectedViewControllerAtIndex:self.selectedIndex-1])
        [self handleEdgePanGesture:sender fromTheLeft:YES];
}
- (IBAction)gotRightEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
    if (self.selectedIndex < self.viewControllers.count-1 && [self shouldAcceptUserSelectedViewControllerAtIndex:self.selectedIndex+1])
        [self handleEdgePanGesture:sender fromTheLeft:NO];
}

// allow swipe gestures to combine with any applicable content gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark - Wrappers for delegate methods

- (BOOL)shouldSelectViewControllerAtIndex:(NSInteger)index
{
	if (! [self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
		return YES;
	else
		return [self.delegate tabBarController:self shouldSelectViewController:self.viewControllers[index]];
}
- (BOOL)shouldAcceptUserSelectedViewControllerAtIndex:(NSInteger)index
{
	if (! [self.delegate respondsToSelector:@selector(tabBarController:shouldAcceptUserSelectedViewController:)])
		;
	else if (! [(id <GestureDrivenTabControllerDelegate>)self.delegate tabBarController:self shouldAcceptUserSelectedViewController:self.viewControllers[index]])
		return NO;
	
	return [self shouldSelectViewControllerAtIndex:index];
}
- (void)didSelectViewControllerAtIndex:(NSInteger)index
{
	if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
		[self.delegate tabBarController:self didSelectViewController:self.viewControllers[index]];
}

@end
