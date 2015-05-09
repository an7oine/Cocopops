//
//  2015 Magna cum laude. PD
//

#import "UIPopoverController+UniversalSupport.h"

// Graphical properties of popovers on the iPhone:

#define SPACE_INSET 80.0f	// additional inset along whichever screen axis is longer

#define ARROW_SIZE 10.0f	// height (width) of the arrow when pointing up or down (left or right)
#define CORNER_SIZE 6.0f	// height and width of the rounded corners applied to popover content


UIInterfaceOrientation UInterfaceOrientationWithDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
	switch (deviceOrientation)
	{
		case UIDeviceOrientationLandscapeLeft: return UIInterfaceOrientationLandscapeLeft;
		case UIDeviceOrientationLandscapeRight: return UIInterfaceOrientationLandscapeRight;
		case UIDeviceOrientationPortrait: return UIInterfaceOrientationPortrait;
		case UIDeviceOrientationPortraitUpsideDown: return UIInterfaceOrientationPortraitUpsideDown;
		default: return UIInterfaceOrientationUnknown;
	}
}

@interface PhonePopoverController : UIPopoverController @end

@implementation UIPopoverController (UniversalSupport)
+ (UIPopoverController *)popoverControllerWithContentViewController:(UIViewController *)contentViewController
{
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
		return [[UIPopoverController alloc] initWithContentViewController:contentViewController];
	else
		return [[PhonePopoverController alloc] initWithContentViewController:contentViewController];
}
@end

@implementation PhonePopoverController
{
	UIView *_popoverView, *_backgroundView;

	CAShapeLayer *_arrowShapeLayer;

	UIDeviceOrientation _deviceOrientation;
	UIInterfaceOrientation _interfaceOrientation;

	UIView *_showFromView;
	CGRect _showFromRect;

	UIPopoverArrowDirection _permittedArrowDirections;
}

+ (BOOL)_popoversDisabled { return NO; } // override super's behaviour

@synthesize popoverVisible=_popoverVisible;

#pragma mark - View setup

- (void)setupViewFrames
{
	// get screen size
	CGRect screen = UIScreen.mainScreen.bounds;
	// swap width & height when orientation is landscape, but only on iOS 7
	if ([UIDevice.currentDevice.systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending && _deviceOrientation != UIDeviceOrientationPortrait)
		_backgroundView.frame = (CGRect){ screen.origin, CGSizeMake(screen.size.height, screen.size.width) };
	else
		_backgroundView.frame = screen;

	// get the target on-screen rect, or whole screen if no target view was specified
	CGRect targetRect = _showFromView? [_backgroundView convertRect:_showFromRect fromView:_showFromView] : _backgroundView.bounds;

	CGFloat top = (self.popoverLayoutMargins.top ?: 10.0f) + UIApplication.sharedApplication.statusBarFrame.size.height;
	CGFloat bottom = self.popoverLayoutMargins.bottom ?: 10.0f;
	CGFloat left = self.popoverLayoutMargins.left ?: 10.0f;
	CGFloat right = self.popoverLayoutMargins.right ?: 10.0f;
	
	// determine maximal popover size (as bounded screen real estate)
	CGSize popoverSize = CGSizeMake(_backgroundView.bounds.size.width - left-right, _backgroundView.bounds.size.height - top-bottom);
	// reserve space for cancellation taps along the larger axis
	if (popoverSize.width > popoverSize.height)
		popoverSize.width -= 2*SPACE_INSET;
	else
		popoverSize.height -= 2*SPACE_INSET;

	// allow further shrinking of the popover on either axis
	CGSize minimumPopoverSize = CGSizeMake(popoverSize.width - SPACE_INSET, popoverSize.height - SPACE_INSET);

	// get the size needed for content and bound popover sizes by it
	CGSize contentSize = self.contentViewController.preferredContentSize;
	if (contentSize.width > 0.0f && contentSize.height > 0.0f)
	{
		popoverSize.width = MIN(popoverSize.width, contentSize.width);
		popoverSize.height = MIN(popoverSize.height, contentSize.height);
		minimumPopoverSize.width = MIN(minimumPopoverSize.width, contentSize.width);
		minimumPopoverSize.height = MIN(minimumPopoverSize.height, contentSize.height);
	}
	else
		NSLog(@"%@: contentViewController reports a preferredContentSize of %@", NSStringFromClass(self.class), NSStringFromCGSize(self.contentViewController.preferredContentSize));

	// determine presentation frame of the popover and corner points of the arrow symbol, if appropriate
	CGRect popoverFrame;
	BOOL showArrow = NO;
	CGPoint arrow0, arrow1, arrow2;

	// present popover in the bottom of the screen, if it fits
	if ((_permittedArrowDirections & UIPopoverArrowDirectionUp)
		&& CGRectGetMaxY(targetRect) + ARROW_SIZE + minimumPopoverSize.height + bottom <= CGRectGetMaxY(_backgroundView.bounds)
		&& CGRectGetMidX(targetRect) - ARROW_SIZE - CORNER_SIZE-left >= CGRectGetMinX(_backgroundView.bounds)
		&& CGRectGetMidX(targetRect) + ARROW_SIZE + CORNER_SIZE+right <= CGRectGetMaxX(_backgroundView.bounds))
	{
		// align the popover horizontally with targetRect (directly below it)
		popoverSize.height = MIN(popoverSize.height, CGRectGetHeight(_backgroundView.bounds) - bottom - CGRectGetMaxY(targetRect) - ARROW_SIZE);
		popoverFrame.origin.x = MIN(CGRectGetMaxX(_backgroundView.bounds) - right - popoverSize.width, MAX(left, CGRectGetMidX(targetRect)-0.5f*popoverSize.width));
		popoverFrame.origin.y = CGRectGetMaxY(targetRect) + ARROW_SIZE;
		popoverFrame.size = popoverSize;

		arrow0 = CGPointMake(CGRectGetMidX(targetRect), CGRectGetMaxY(targetRect));
		arrow1 = CGPointMake(CGRectGetMidX(targetRect)-ARROW_SIZE, CGRectGetMaxY(targetRect)+ARROW_SIZE);
		arrow2 = CGPointMake(CGRectGetMidX(targetRect)+ARROW_SIZE, CGRectGetMaxY(targetRect)+ARROW_SIZE);
		showArrow = YES;
	}

	// present popover in the top of the screen, if it fits
	else if ((_permittedArrowDirections & UIPopoverArrowDirectionDown)
		&& CGRectGetMinY(targetRect) - ARROW_SIZE - minimumPopoverSize.height - top >= CGRectGetMinY(_backgroundView.bounds)
		&& CGRectGetMidX(targetRect) - ARROW_SIZE - CORNER_SIZE-left >= CGRectGetMinX(_backgroundView.bounds)
		&& CGRectGetMidX(targetRect) + ARROW_SIZE + CORNER_SIZE+right <= CGRectGetMaxX(_backgroundView.bounds))
	{
		// align the popover horizontally with targetRect (directly above it)
		popoverSize.height = MIN(popoverSize.height, CGRectGetMinY(targetRect) - ARROW_SIZE - top);
		popoverFrame.origin.x = MIN(CGRectGetMaxX(_backgroundView.bounds) - right - popoverSize.width, MAX(left, CGRectGetMidX(targetRect)-0.5f*popoverSize.width));
		popoverFrame.origin.y = CGRectGetMinY(targetRect) - ARROW_SIZE - popoverSize.height;
		popoverFrame.size = popoverSize;

		arrow0 = CGPointMake(CGRectGetMidX(targetRect), CGRectGetMinY(targetRect));
		arrow1 = CGPointMake(CGRectGetMidX(targetRect)+ARROW_SIZE, CGRectGetMinY(targetRect)-ARROW_SIZE);
		arrow2 = CGPointMake(CGRectGetMidX(targetRect)-ARROW_SIZE, CGRectGetMinY(targetRect)-ARROW_SIZE);
		showArrow = YES;
	}

	// present popover on the right side of the screen, if it fits
	else if ((_permittedArrowDirections & UIPopoverArrowDirectionLeft)
		&& CGRectGetMaxX(targetRect) + ARROW_SIZE + minimumPopoverSize.width + right <= CGRectGetMaxX(_backgroundView.bounds))
	{
		// align the popover vertically with targetRect (directly on its right)
		popoverSize.width = MIN(popoverSize.width, CGRectGetWidth(_backgroundView.bounds) - right - CGRectGetMaxX(targetRect) - ARROW_SIZE);
		popoverFrame.origin.x = CGRectGetMaxX(targetRect) + ARROW_SIZE;
		popoverFrame.origin.y = MIN(CGRectGetMaxY(_backgroundView.bounds) - bottom - popoverSize.height, MAX(top, CGRectGetMidY(targetRect)-0.5f*popoverSize.height));
		popoverFrame.size = popoverSize;

		arrow0 = CGPointMake(CGRectGetMaxX(targetRect), CGRectGetMidY(targetRect));
		arrow1 = CGPointMake(CGRectGetMaxX(targetRect)+ARROW_SIZE, CGRectGetMidY(targetRect)+ARROW_SIZE);
		arrow2 = CGPointMake(CGRectGetMaxX(targetRect)+ARROW_SIZE, CGRectGetMidY(targetRect)-ARROW_SIZE);
		showArrow = YES;
	}

	// present popover on the left side of the screen, if it fits
	else if ((_permittedArrowDirections & UIPopoverArrowDirectionRight)
		&& CGRectGetMinX(targetRect) - ARROW_SIZE - minimumPopoverSize.width - left >= CGRectGetMinX(_backgroundView.bounds))
	{
		// align the popover vertically with targetRect (directly on its left)
		popoverSize.width = MIN(popoverSize.width, CGRectGetMinX(targetRect) - ARROW_SIZE - left);
		popoverFrame.origin.x = CGRectGetMinX(targetRect) - ARROW_SIZE - popoverSize.width;
		popoverFrame.origin.y = MIN(CGRectGetMaxY(_backgroundView.bounds) - bottom - popoverSize.height, MAX(top, CGRectGetMidY(targetRect)-0.5f*popoverSize.height));
		popoverFrame.size = popoverSize;

		arrow0 = CGPointMake(CGRectGetMinX(targetRect), CGRectGetMidY(targetRect));
		arrow1 = CGPointMake(CGRectGetMinX(targetRect)-ARROW_SIZE, CGRectGetMidY(targetRect)-ARROW_SIZE);
		arrow2 = CGPointMake(CGRectGetMinX(targetRect)-ARROW_SIZE, CGRectGetMidY(targetRect)+ARROW_SIZE);
		showArrow = YES;
	}

	// otherwise, present centered on screen (without arrow)
	else
	{
		popoverFrame = CGRectInset((CGRect){ CGPointMake(CGRectGetMidX(_backgroundView.bounds), CGRectGetMidY(_backgroundView.bounds)), CGSizeZero }, -0.5f*popoverSize.width, -0.5f*popoverSize.height);
		showArrow = NO;
	}

	_popoverView.frame = popoverFrame;
	self.contentViewController.view.frame = _popoverView.bounds;

	if (showArrow)
	{
		CGMutablePathRef arrowShapePath = CGPathCreateMutable();
		CGPathMoveToPoint(arrowShapePath, NULL, arrow0.x, arrow0.y);
		CGPathAddLineToPoint(arrowShapePath, NULL, arrow1.x, arrow1.y);
		CGPathAddLineToPoint(arrowShapePath, NULL, arrow2.x, arrow2.y);
		CGPathCloseSubpath(arrowShapePath);
		_arrowShapeLayer.frame = _backgroundView.bounds;
		_arrowShapeLayer.path = arrowShapePath;
		_arrowShapeLayer.fillColor = UIColor.whiteColor.CGColor;
		_arrowShapeLayer.strokeColor = UIColor.whiteColor.CGColor;
		_arrowShapeLayer.lineJoin = kCALineJoinRound;
		CGPathRelease(arrowShapePath);
	}
	else
		_arrowShapeLayer.path = NULL;


	// set a content mask with rounded corners
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	CGPathRef roundedRectPath = CGPathCreateWithRoundedRect(_popoverView.bounds, CORNER_SIZE, CORNER_SIZE, NULL);
	maskLayer.frame = _popoverView.bounds;
	maskLayer.path = roundedRectPath;
	CGPathRelease(roundedRectPath);
	_popoverView.layer.mask = maskLayer;
}

- (void)setupViewHierarchy
{
	_arrowShapeLayer = [[CAShapeLayer alloc] init];
	[_backgroundView.layer addSublayer:_arrowShapeLayer];

	[_popoverView addSubview:self.contentViewController.view];
	[_backgroundView addSubview:_popoverView];

	if ([UIDevice.currentDevice.systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)
		// attach onto an existing viewController's view on iOS 7
		[UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:_backgroundView];
	else
		// attach onto the application window on iOS 8
		[UIApplication.sharedApplication.keyWindow addSubview:_backgroundView];
}


#pragma mark - Notifications and Actions

- (void)deviceOrientationDidChange:(NSNotification*)notification
{
	UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
	UIInterfaceOrientation interfaceOrientation = UInterfaceOrientationWithDeviceOrientation(deviceOrientation);

	_deviceOrientation = deviceOrientation;
	[self.contentViewController willRotateToInterfaceOrientation:interfaceOrientation duration:0.3f];
	[UIView animateWithDuration:0.3f animations:^
	{
		[self.contentViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:0.3f];
		[self setupViewFrames];
	} completion:^(BOOL finished)
	{
		[self.contentViewController didRotateFromInterfaceOrientation:_interfaceOrientation];
		_interfaceOrientation = interfaceOrientation;
	}];
}

- (IBAction)backgroundViewTapped:(UITapGestureRecognizer *)sender
{
	CGPoint point = [sender locationInView:_backgroundView];
	if (! CGRectContainsPoint(_popoverView.frame, point))
		[self dismissPopoverAnimated:YES];
}


#pragma mark - Presentation & Dismissal

- (void)presentPopoverAnimated:(BOOL)animated
{
	UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
	recogniser.cancelsTouchesInView = NO;

	_backgroundView = [[self.popoverBackgroundViewClass ?: UIView.class alloc] initWithFrame:CGRectZero];
	[_backgroundView addGestureRecognizer:recogniser];
	_backgroundView.backgroundColor = self.backgroundColor ?: [UIColor colorWithWhite:0.0f alpha:0.15f];

	_popoverView = [[UIView alloc] initWithFrame:CGRectZero];
	_popoverView.opaque = NO;

	// resign any first responder to free more screen space
	[UIApplication.sharedApplication.keyWindow endEditing:YES];

	// get initial device orientation
	_deviceOrientation = UIDevice.currentDevice.orientation;
	if (_deviceOrientation == UIDeviceOrientationUnknown)
		_deviceOrientation = UIDeviceOrientationPortrait;
	_interfaceOrientation = UInterfaceOrientationWithDeviceOrientation(_deviceOrientation);

	// set to receive updates of device orientation
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
	[UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];

	// setup views & frames
	[self setupViewHierarchy];
	[self setupViewFrames];
	_popoverVisible = YES;

	[self.contentViewController viewWillAppear:YES];

	// present the views instantly or animated
	if (animated)
	{
		_popoverView.userInteractionEnabled = NO;
		_backgroundView.alpha = 0.0f;

		[UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^
		 {
			 _backgroundView.alpha = 1.0f;
		 } completion:^(BOOL finished)
		 {
			 _popoverView.userInteractionEnabled = YES;
			 [self.contentViewController viewDidAppear:YES];
			 [_popoverView becomeFirstResponder];
		 }];
	}
	else
	{
		_backgroundView.alpha = 1.0f;
		[self.contentViewController viewDidAppear:YES];
		[_popoverView becomeFirstResponder];
	}
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
	// get the bar button's view (hack-ish)
	_showFromView = [item valueForKey:@"view"];
	_showFromRect = _showFromView.bounds;
	_permittedArrowDirections = arrowDirections;
	[self presentPopoverAnimated:animated];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
	_showFromView = view;
	_showFromRect = rect;
	_permittedArrowDirections = arrowDirections;
	[self presentPopoverAnimated:animated];
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
	[UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if (_popoverView)
	{
		[self.contentViewController viewWillDisappear:animated];

		[_popoverView resignFirstResponder];
		if (animated)
		{
			_popoverView.userInteractionEnabled = NO;

			[UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^
			 {
				 _backgroundView.alpha = 0.0;
			 } completion:^(BOOL finished)
			 {
				 [self.contentViewController viewDidDisappear:animated];
				 [_backgroundView removeFromSuperview];
				 _backgroundView = nil;
				 _popoverView = nil;
				 _popoverVisible = NO;
			 }];
		}
		else
		{
			[self.contentViewController viewDidDisappear:animated];
			[_backgroundView removeFromSuperview];
			_backgroundView = nil;
			_popoverView = nil;
			_popoverVisible = NO;
		}
	}
}

@end
