//
//  2015 Magna cum laude. PD
//

#import "UIPopoverController+UniversalSupport.h"

#import "UIApplication+KeyboardFrame.h"


// Graphical properties of popovers displayed on the iPhone:

#define MINIMUM_SIZE 0.8f	// minimum size of the displayed popover, fraction of each dimension
#define ARROW_SIZE 10.0f	// height (width) of the arrow when pointing up or down (left or right)
#define CORNER_SIZE 6.0f	// height and width of the rounded corners applied to popover content


UIInterfaceOrientation UInterfaceOrientationWithDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
	switch (deviceOrientation)
	{
		case UIDeviceOrientationLandscapeLeft: return UIInterfaceOrientationLandscapeLeft;
		case UIDeviceOrientationLandscapeRight: return UIInterfaceOrientationLandscapeRight;
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		case UIDeviceOrientationPortrait: return UIInterfaceOrientationPortrait;
		case UIDeviceOrientationPortraitUpsideDown: return UIInterfaceOrientationPortraitUpsideDown;
		case UIDeviceOrientationUnknown:
		default: return UIInterfaceOrientationPortrait;
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
	UIView *_popoverView, *_arrowView, *_backgroundView;

	CAShapeLayer *_arrowShapeLayer;

	UIDeviceOrientation _deviceOrientation;
	UIInterfaceOrientation _interfaceOrientation;

	UIView *_showFromView;
	CGRect _showFromRect;
	UIBarButtonItem *_showFromBarButtonItem;

	UIPopoverArrowDirection _permittedArrowDirections;
	
	BOOL _registeredForPreferredContentSizeObserving;
}

+ (BOOL)_popoversDisabled { return NO; } // override super's behaviour

@synthesize popoverLayoutMargins=_popoverLayoutMargins;
@synthesize popoverVisible=_popoverVisible;
@synthesize popoverArrowDirection=_popoverArrowDirection;
@synthesize popoverContentSize=_popoverContentSize;

- (CGSize)popoverContentSize
{
	return _popoverContentSize.width > 0.0f && _popoverContentSize.height > 0.0f? _popoverContentSize : self.contentViewController.preferredContentSize;
}
- (void)setPopoverContentSize:(CGSize)popoverContentSize
{
	[self setPopoverContentSize:popoverContentSize animated:_popoverVisible];
}
- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated
{
	_popoverContentSize = size;
	if (_popoverVisible)
	{
		if (animated)
			[UIView animateWithDuration:0.3f animations:^
			{
				[self setupViewFramesFirstTime:NO];
			} completion:nil];
		else
			[self setupViewFramesFirstTime:NO];
	}
}


#pragma mark - Initialising

- (instancetype)initWithContentViewController:(UIViewController *)viewController
{
	if (! (self = [super initWithContentViewController:viewController]))
		return nil;
	_popoverLayoutMargins = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
	_popoverVisible = NO;
	_popoverArrowDirection = UIPopoverArrowDirectionUnknown;
	return self;
}


#pragma mark - Helpers

+ (CGRect)adjustHorizontally:(CGRect)rect toBounds:(CGRect)bounds
{
	if (CGRectGetMinX(rect) < CGRectGetMinX(bounds))
	return CGRectOffset(rect, CGRectGetMinX(bounds)-CGRectGetMinX(rect), 0.0f);
	else if (CGRectGetMaxX(rect) > CGRectGetMaxX(bounds))
	return CGRectOffset(rect, CGRectGetMaxX(bounds)-CGRectGetMaxX(rect), 0.0f);
	else
	return rect;
}
+ (CGRect)adjustVertically:(CGRect)rect toBounds:(CGRect)bounds
{
	if (CGRectGetMinY(rect) < CGRectGetMinY(bounds))
	return CGRectOffset(rect, 0.0f, CGRectGetMinY(bounds)-CGRectGetMinY(rect));
	else if (CGRectGetMaxY(rect) > CGRectGetMaxY(bounds))
	return CGRectOffset(rect, 0.0f, CGRectGetMaxY(bounds)-CGRectGetMaxY(rect));
	else
	return rect;
}

+ (CGPathRef)newArrowToDirection:(UIPopoverArrowDirection)dir
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(ARROW_SIZE, ARROW_SIZE), 1.0f, 1.0f);
	switch (dir)
	{
			case UIPopoverArrowDirectionLeft:
			CGPathMoveToPoint(path, &transform, 0.0f, -1.0f);
			CGPathAddCurveToPoint(path, &transform, 0.0f, -0.5f, -1.0f, -0.3f, -1.0f, 0.0f);
			CGPathAddCurveToPoint(path, &transform, -1.0f, 0.3f, 0.0f, 0.5f, 0.0f, 1.0f);
			break;
			case UIPopoverArrowDirectionRight:
			CGPathMoveToPoint(path, &transform, 0.0f, 1.0f);
			CGPathAddCurveToPoint(path, &transform, 0.0f, 0.5f, 1.0f, 0.3f, 1.0f, 0.0f);
			CGPathAddCurveToPoint(path, &transform, 1.0f, -0.3f, 0.0f, -0.5f, 0.0f, -1.0f);
			break;
			case UIPopoverArrowDirectionUp:
			CGPathMoveToPoint(path, &transform, 1.0f, 0.0f);
			CGPathAddCurveToPoint(path, &transform, 0.5f, 0.0f, 0.3f, -1.0f, 0.0f, -1.0f);
			CGPathAddCurveToPoint(path, &transform, -0.3f, -1.0f, -0.5f, 0.0f, -1.0f, 0.0f);
			break;
			case UIPopoverArrowDirectionDown:
			CGPathMoveToPoint(path, &transform, -1.0f, 0.0f);
			CGPathAddCurveToPoint(path, &transform, -0.5f, 0.0f, -0.3f, 1.0f, 0.0f, 1.0f);
			CGPathAddCurveToPoint(path, &transform, 0.3f, 1.0f, 0.5f, 0.0f, 1.0f, 0.0f);
			break;
		default:
			break;
	}
	CGPathCloseSubpath(path);
	return path;
}


#pragma mark - View setup

- (void)setupViewHierarchy
{
	UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
	recogniser.cancelsTouchesInView = NO;

	_backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	[_backgroundView addGestureRecognizer:recogniser];
	_backgroundView.backgroundColor = self.backgroundColor ?: [UIColor colorWithWhite:0.0f alpha:0.15f];

	_popoverView = [[UIView alloc] initWithFrame:CGRectZero];
	_popoverView.opaque = NO;
	
	if (NSClassFromString(@"UIVisualEffectView") != Nil)
		_arrowView = [[UIVisualEffectView alloc] initWithEffect:[[UIBlurEffect alloc] init]];
	else
	{
		_arrowView = [[UIView alloc] initWithFrame:CGRectZero];
		_arrowView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
	}
	[_backgroundView addSubview:_arrowView];

	_arrowShapeLayer = [[CAShapeLayer alloc] init];
	_arrowView.layer.mask = _arrowShapeLayer;

	[_popoverView addSubview:self.contentViewController.view];
	[_backgroundView addSubview:_popoverView];

	//if ([UIDevice.currentDevice.systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)
		// attach onto an existing viewController's view on iOS 7 (does not seem to work?)
		// [UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:_backgroundView];
	//else
		// attach directly onto the application window on iOS 8+ (and 7)
		[UIApplication.sharedApplication.keyWindow addSubview:_backgroundView];
}

- (void)setupViewFramesFirstTime:(BOOL)firstTime
{
	// get screen frame, exclude status bar frame
	CGRect screen = UIScreen.mainScreen.bounds;
	CGSize statusBarSize = UIApplication.sharedApplication.statusBarFrame.size;
	CGSize inputViewSize = UIApplication.sharedApplication.keyboardFrame.size;

	// swap width & height when orientation is landscape, but only on iOS 7
	if ([UIDevice.currentDevice.systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending && _interfaceOrientation != UIInterfaceOrientationPortrait)
	{
		screen = (CGRect){ screen.origin, CGSizeMake(screen.size.height, screen.size.width) };
		statusBarSize = CGSizeMake(statusBarSize.height, statusBarSize.width);
		inputViewSize = CGSizeMake(inputViewSize.height, inputViewSize.width);
	}
	_backgroundView.frame = screen;
	BOOL landscape = screen.size.width > screen.size.height;

	// get the margin width on each screen edge
	CGFloat top = self.popoverLayoutMargins.top + statusBarSize.height;
	CGFloat bottom = self.popoverLayoutMargins.bottom + inputViewSize.height;
	CGFloat left = self.popoverLayoutMargins.left;
	CGFloat right = self.popoverLayoutMargins.right;

	// determine usable on-screen area, preferred popover size, and minimum required popover size
	CGRect usable = CGRectMake(CGRectGetMinX(_backgroundView.bounds)+left, CGRectGetMinY(_backgroundView.bounds)+top, CGRectGetWidth(_backgroundView.bounds)-left-right, CGRectGetHeight(_backgroundView.bounds)-top-bottom);
	CGRect popover = (CGRect){ CGPointZero, self.popoverContentSize };
	if (popover.size.width == 0.0f || popover.size.width > usable.size.width)
		popover.size.width = usable.size.width;
	if (popover.size.height == 0.0f || popover.size.height > usable.size.height)
		popover.size.height = usable.size.height;

	// determine a minimum size for the presented popover
	CGSize minimumSize = CGSizeMake(MINIMUM_SIZE * popover.size.width, MINIMUM_SIZE * popover.size.height);
	if (landscape)
		minimumSize.width *= 0.5f;
	else
		minimumSize.height *= 0.5f;

	// target a specific rectangle on screen, or whole screen if none was specified
	CGRect target = _backgroundView.bounds;
	if (_showFromView)
		target = [_backgroundView convertRect:_showFromRect fromView:_showFromView];
	else if (_showFromBarButtonItem)
	{
		UIView *barButtonItemView = [_showFromBarButtonItem valueForKey:@"view"];
		target = [_backgroundView convertRect:barButtonItemView.bounds fromView:barButtonItemView];
	}

	// determine which direction the arrow should point, if at all
	UIPopoverArrowDirection dir = UIPopoverArrowDirectionUnknown;
	CGRect arrow = CGRectMake(0.0f, 0.0f, 2*ARROW_SIZE, 2*ARROW_SIZE);

	CGFloat leftSpace = CGRectGetMinX(target) - ARROW_SIZE - popover.size.width - CGRectGetMinX(usable);
	CGFloat rightSpace = CGRectGetMaxX(usable) - (CGRectGetMaxX(target) + ARROW_SIZE + minimumSize.width);
	CGFloat upSpace = CGRectGetMinY(target) - ARROW_SIZE - popover.size.height - CGRectGetMinY(usable);
	CGFloat downSpace = CGRectGetMaxY(usable) - (CGRectGetMaxY(target) + ARROW_SIZE + popover.size.height);

	CGFloat bestSpace = -MAX(popover.size.width, popover.size.height);
	UIPopoverArrowDirection bestDir = UIPopoverArrowDirectionUnknown;
	if ((_permittedArrowDirections & UIPopoverArrowDirectionUp) && downSpace > bestSpace)
	{
		bestSpace = downSpace;
		bestDir = UIPopoverArrowDirectionUp;
	}
	if ((_permittedArrowDirections & UIPopoverArrowDirectionDown) && upSpace > bestSpace)
	{
		bestSpace = upSpace;
		bestDir = UIPopoverArrowDirectionDown;
	}
	if ((_permittedArrowDirections & UIPopoverArrowDirectionLeft) && rightSpace > bestSpace)
	{
		bestSpace = rightSpace;
		bestDir = UIPopoverArrowDirectionLeft;
	}
	if ((_permittedArrowDirections & UIPopoverArrowDirectionRight) && leftSpace > bestSpace)
	{
		//bestSpace = leftSpace;
		bestDir = UIPopoverArrowDirectionRight;
	}

	if (bestDir == UIPopoverArrowDirectionUp)
	{
		popover = CGRectOffset(popover, CGRectGetMidX(target)-0.5f*popover.size.width, CGRectGetMaxY(target)+ARROW_SIZE);
		popover = [self.class adjustHorizontally:popover toBounds:usable];

		dir = UIPopoverArrowDirectionUp;
		arrow.origin = CGPointMake(CGRectGetMidX(target)-ARROW_SIZE, CGRectGetMaxY(target));
	}

	else if (bestDir == UIPopoverArrowDirectionDown)
	{
		popover = CGRectOffset(popover, CGRectGetMidX(target)-0.5f*popover.size.width, CGRectGetMinY(target)-ARROW_SIZE-popover.size.height);
		popover = [self.class adjustHorizontally:popover toBounds:usable];

		dir = UIPopoverArrowDirectionDown;
		arrow.origin = CGPointMake(CGRectGetMidX(target)-ARROW_SIZE, CGRectGetMinY(target)-2*ARROW_SIZE);
	}

	else if (bestDir == UIPopoverArrowDirectionLeft)
	{
		popover = CGRectOffset(popover, CGRectGetMaxX(target)+ARROW_SIZE, CGRectGetMidY(target)-0.5f*popover.size.height);
		popover = [self.class adjustVertically:popover toBounds:usable];

		dir = UIPopoverArrowDirectionLeft;
		arrow.origin = CGPointMake(CGRectGetMaxX(target), CGRectGetMidY(target)-ARROW_SIZE);
	}

	else if (bestDir == UIPopoverArrowDirectionRight)
	{
		popover = CGRectOffset(popover, CGRectGetMinX(target)-ARROW_SIZE-popover.size.width, CGRectGetMidY(target)-0.5f*popover.size.height);
		popover = [self.class adjustVertically:popover toBounds:usable];

		dir = UIPopoverArrowDirectionRight;
		arrow.origin = CGPointMake(CGRectGetMinX(target)-2*ARROW_SIZE, CGRectGetMidY(target)-ARROW_SIZE);
	}

	else
		popover = CGRectInset(usable, 0.5f*(usable.size.width-minimumSize.width), 0.5f*(usable.size.height-minimumSize.height));

	// clip to usable area
	popover = CGRectIntersection(popover, usable);

	// give the delegate a chance to propose a new frame upon popover reposition
	if (! firstTime && [self.delegate respondsToSelector:@selector(popoverController:willRepositionPopoverToRect:inView:)])
	{
		CGRect proposedFrame = popover;
		UIView *proposedView = _backgroundView.superview;
		[self.delegate popoverController:self willRepositionPopoverToRect:&proposedFrame inView:&proposedView];
		proposedFrame = CGRectIntersection(proposedFrame, usable);
		if (dir == UIPopoverArrowDirectionLeft)
			arrow = CGRectOffset(arrow, CGRectGetMinX(proposedFrame)-CGRectGetMinX(popover), CGRectGetMidY(proposedFrame)-CGRectGetMidY(popover));
		else if (dir == UIPopoverArrowDirectionRight)
			arrow = CGRectOffset(arrow, CGRectGetMaxX(proposedFrame)-CGRectGetMaxX(popover), CGRectGetMidY(proposedFrame)-CGRectGetMidY(popover));
		else if (dir == UIPopoverArrowDirectionUp)
			arrow = CGRectOffset(arrow, CGRectGetMidX(proposedFrame)-CGRectGetMidX(popover), CGRectGetMinX(proposedFrame)-CGRectGetMinX(popover));
		else if (dir == UIPopoverArrowDirectionDown)
			arrow = CGRectOffset(arrow, CGRectGetMidX(proposedFrame)-CGRectGetMidX(popover), CGRectGetMaxX(proposedFrame)-CGRectGetMaxX(popover));
		popover = proposedFrame;
		[proposedView addSubview:_backgroundView];
	}

	// setup popover frame and content frame
	_popoverView.frame = popover;
	self.contentViewController.view.frame = _popoverView.bounds;

	// setup _arrowShapeLayer path & position
	if (dir != UIPopoverArrowDirectionUnknown)
	{
		if (dir==UIPopoverArrowDirectionUp || dir==UIPopoverArrowDirectionDown)
			_arrowView.frame = [self.class adjustHorizontally:arrow toBounds:CGRectInset(usable, CORNER_SIZE, 0.0f)];
		else
			_arrowView.frame = [self.class adjustVertically:arrow toBounds:CGRectInset(usable, 0.0f, CORNER_SIZE)];

		CGPathRef path = [self.class newArrowToDirection:dir];
		_arrowShapeLayer.frame = _arrowView.bounds;
		_arrowShapeLayer.path = path;
		CGPathRelease(path);
	}
	else
		_arrowShapeLayer.path = NULL;
	_popoverArrowDirection = dir;

	// setup content mask with rounded corners
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	CGPathRef roundedRectPath = CGPathCreateWithRoundedRect(_popoverView.bounds, MIN(0.5f*_popoverView.bounds.size.width, CORNER_SIZE), MIN(0.5f*_popoverView.bounds.size.height, CORNER_SIZE), NULL);
	maskLayer.frame = _popoverView.bounds;
	maskLayer.path = roundedRectPath;
	CGPathRelease(roundedRectPath);
	_popoverView.layer.mask = maskLayer;
}


#pragma mark - Notifications and Actions

- (void)deviceOrientationDidChange:(NSNotification*)notification
{
	/*
	if (_showFromBarButtonItem)
	{
		[self dismissPopoverAnimated:NO];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
		{
			[self presentPopoverFromBarButtonItem:_showFromBarButtonItem permittedArrowDirections:_permittedArrowDirections animated:NO];
		});
		return;
	}
	*/

	UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
	UIInterfaceOrientation interfaceOrientation = UInterfaceOrientationWithDeviceOrientation(deviceOrientation);

	_deviceOrientation = deviceOrientation;
	[self.contentViewController willRotateToInterfaceOrientation:interfaceOrientation duration:0.3f];
	[UIView animateWithDuration:0.3f animations:^
	{
		[self.contentViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:0.3f];
		[self setupViewFramesFirstTime:NO];
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
	{
		if (! [self.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)] || [self.delegate popoverControllerShouldDismissPopover:self])
		{
			[self dismissPopoverAnimated:YES];
			if ([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
				[self.delegate popoverControllerDidDismissPopover:self];
		}
	}
}


#pragma mark - Presentation & Dismissal

- (void)presentPopoverAnimated:(BOOL)animated
{
	// get initial device orientation
	_deviceOrientation = UIDevice.currentDevice.orientation;
	if (_deviceOrientation == UIDeviceOrientationUnknown)
		_deviceOrientation = UIDeviceOrientationPortrait;
	_interfaceOrientation = UInterfaceOrientationWithDeviceOrientation(_deviceOrientation);

	// set to receive updates of device orientation
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
	//[UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];

	// setup views & frames
	[self setupViewHierarchy];
	[self setupViewFramesFirstTime:YES];
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
	
	// set to observe future changes to the preferredContentSize property
	if (! _registeredForPreferredContentSizeObserving)
	{
		[self.contentViewController addObserver:self forKeyPath:@"preferredContentSize" options:NSKeyValueObservingOptionNew context:(__bridge void *)PhonePopoverController.class];
		_registeredForPreferredContentSizeObserving = YES;
	}
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
	// get the bar button's view via KVC
	//_showFromView = [item valueForKey:@"view"];
	//_showFromRect = _showFromView.bounds;
	_showFromBarButtonItem = item;
	_permittedArrowDirections = arrowDirections;
	//if (_showFromView)
	//	self.passthroughViews = [@[ _showFromView.superview, ] arrayByAddingObjectsFromArray:self.passthroughViews];
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
	if (_registeredForPreferredContentSizeObserving)
	{
		[self.contentViewController removeObserver:self forKeyPath:@"preferredContentSize" context:(__bridge void *)PhonePopoverController.class];
		_registeredForPreferredContentSizeObserving = NO;
	}

	//[UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
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
				 _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
			 }];
		}
		else
		{
			[self.contentViewController viewDidDisappear:animated];
			[_backgroundView removeFromSuperview];
			_backgroundView = nil;
			_popoverView = nil;
			_popoverVisible = NO;
			_popoverArrowDirection = UIPopoverArrowDirectionUnknown;
		}
	}
}


#pragma mark - Observance

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if (context != (__bridge void *)PhonePopoverController.class)
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	else if ([keyPath isEqualToString:@"preferredContentSize"])
		self.popoverContentSize = self.contentViewController.preferredContentSize;
}

@end
