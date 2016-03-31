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

- (void)handleEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender fromTheLeft:(BOOL)fromTheLeft toIndex:(NSInteger)index
{
    UIView *containerView = self.view;

	// get the outgoing VC and its view
	UIViewController *outgoingVC = self.selectedViewController;
    UIView *outgoingView = outgoingVC.view;

	// get the incoming VC and its view
	UIViewController *incomingVC = self.viewControllers[index];
    UIView *incomingView = incomingVC.view;

	// get the on-screen (horizontal) location and velocity of the gesture
    CGFloat touchLocation = [sender translationInView:containerView].x + (fromTheLeft? 0.0f : CGRectGetWidth(containerView.bounds));
    CGFloat touchVelocity = [sender velocityInView:containerView].x;
	
	BOOL incomingOnTop = NO; 	// display incoming VC on top of outgoing one
	BOOL incomingAnimation = NO; // animate incoming VC onto the screen
	BOOL outgoingAnimation = NO; // animate outgoing VC out of the screen
	switch (self.transitionStyle)
	{
		case kTabTransitionNone: 			incomingOnTop = YES; incomingAnimation = NO; outgoingAnimation = NO; break;
		case kTabTransitionIncomingOnTop:	incomingOnTop = YES; incomingAnimation = YES; outgoingAnimation = NO; break;
		case kTabTransitionOutgoingOnTop:	incomingOnTop = NO; incomingAnimation = NO; outgoingAnimation = YES; break;
		case kTabTransitionLeftOnTop:
			incomingOnTop = fromTheLeft;
			incomingAnimation = fromTheLeft;
			outgoingAnimation = ! fromTheLeft;
			break;
		case kTabTransitionRightOnTop:
			incomingOnTop = ! fromTheLeft;
			incomingAnimation = ! fromTheLeft;
			outgoingAnimation = fromTheLeft;
			break;
		case kTabTransitionSideBySide:		incomingOnTop = NO; incomingAnimation = YES; outgoingAnimation = YES; break;
		default:
			NSLog(@"%@: invalid transitionStyle of %d", NSStringFromClass(self.class), (int)self.transitionStyle);
			break;
	}

    switch (sender.state)
    {
		// ignore non-definitive touches
        case UIGestureRecognizerStatePossible:
            break;

		// when the gesture starts, present the incoming view (above or below existing the existing view) and inform its controller before and after
        case UIGestureRecognizerStateBegan:
		
			// immediately fill the screen with incoming content, or place it just outside the screen, if it is to be animated into place
			if (incomingAnimation)
				incomingView.frame = CGRectOffset(containerView.bounds, (fromTheLeft? -1 : 1) * CGRectGetWidth(containerView.bounds), 0.0f);
			else
				incomingView.frame = containerView.bounds;

			[incomingVC viewWillAppear:NO];

			// manipulate the subview order: place incoming on top, but have the outgoing immediately supersede it, if needed
			// note: -[insertSubView:belowSubview:] does not seem to work correctly here (incoming will always appear on top)
			[containerView insertSubview:incomingView aboveSubview:outgoingView];
			if (! incomingOnTop)
            	[containerView insertSubview:outgoingView aboveSubview:incomingView];
			
			[incomingVC viewDidAppear:NO];
			
            // then fall through to the 'changed' case:

		// each time the user moves their finger, adjust positions of incoming and outgoing views accordingly
        case UIGestureRecognizerStateChanged:
			if (incomingAnimation)
			{
				if (fromTheLeft)
					incomingView.frame = CGRectOffset(containerView.bounds, -CGRectGetWidth(containerView.bounds)+touchLocation, 0.0f);
				else
					incomingView.frame = CGRectOffset(containerView.bounds, touchLocation, 0.0f);
			}
			if (outgoingAnimation)
			{
				if (fromTheLeft)
					outgoingView.frame = CGRectOffset(containerView.bounds, touchLocation, 0.0f);
				else
					outgoingView.frame = CGRectOffset(containerView.bounds, -CGRectGetWidth(containerView.bounds)+touchLocation, 0.0f);
			}
			
            break;

		// when finished, inspect the location and velocity to determine whether the user wants to switch tabs or if they changed their mind halfway through to the gesture
        case UIGestureRecognizerStateEnded:
        {
            // if the gesture in its current state of position + velocity would favour a transition, perform it
            BOOL landingLeft = touchLocation + self.transitionDuration * touchVelocity < CGRectGetMidX(containerView.bounds);
            if (fromTheLeft && ! landingLeft)
            {
				// animate a slide-in from left to right
				[UIView animateWithDuration:self.transitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
				{
					if (incomingAnimation)
						incomingView.frame = containerView.bounds;
					if (outgoingAnimation)
						outgoingView.frame = CGRectOffset(containerView.bounds, containerView.bounds.size.width, 0.0f);
				} completion:^(BOOL finished)
				{
					[outgoingVC viewWillDisappear:NO];
					[outgoingView removeFromSuperview];
					[outgoingVC viewDidDisappear:NO];

					[self setSelectedIndex:index];
					[self didSelectViewControllerAtIndex:index];
				}];
                break;
            }
            else if (! fromTheLeft && landingLeft)
            {
				// animate a slide-in from right to left
				[UIView animateWithDuration:self.transitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
				{
					if (incomingAnimation)
						incomingView.frame = containerView.bounds;
					if (outgoingAnimation)
						outgoingView.frame = CGRectOffset(containerView.bounds, -containerView.bounds.size.width, 0.0f);
				} completion:^(BOOL finished)
				{
					[outgoingVC viewWillDisappear:NO];
					[outgoingView removeFromSuperview];
					[outgoingVC viewDidDisappear:NO];

					[self setSelectedIndex:index];
					[self didSelectViewControllerAtIndex:index];
				}];
                break;
            }
            // otherwise, fall through to the 'failed' case:
        }
		
		// if the gesture fails, is cancelled, or the user did not want a transition, pull back and remove the incoming view
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            // animate a slide-out back to whence the overlay came
            [UIView animateWithDuration:self.transitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^
            {
				if (incomingAnimation)
				{
					if (fromTheLeft)
						incomingView.frame = CGRectOffset(containerView.bounds, -containerView.bounds.size.width, 0.0f);
					else
						incomingView.frame = CGRectOffset(containerView.bounds, containerView.bounds.size.width, 0.0f);
				}
				if (outgoingAnimation)
					outgoingView.frame = containerView.bounds;
            } completion:^(BOOL finished)
            {
				[incomingVC viewWillDisappear:NO];
				[incomingView removeFromSuperview];
				[incomingVC viewDidDisappear:NO];
            }];
            break;
    }
}

// handle user gestures only if not disabled
- (IBAction)gotLeftEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
	NSInteger index = self.selectedIndex-1;
	if (index < 0)
	{
		if (self.isCircular)
			index = self.viewControllers.count-1;
		else
			return;
	}
    if ([self shouldAcceptUserSelectedViewControllerAtIndex:index])
        [self handleEdgePanGesture:sender fromTheLeft:YES toIndex:index];
}
- (IBAction)gotRightEdgePanGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
	NSInteger index = self.selectedIndex+1;
	if (index >= self.viewControllers.count)
	{
		if (self.isCircular)
			index = 0;
		else
			return;
	}
    if ([self shouldAcceptUserSelectedViewControllerAtIndex:index])
        [self handleEdgePanGesture:sender fromTheLeft:NO toIndex:index];
}

// allow edge pan gestures to combine with any other gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
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
