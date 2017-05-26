//
//  2016 Magna cum laude. PD
//

#import "PopoverNavigationController.h"

#import <objc/runtime.h>

@implementation UIGestureRecognizer (TargetAction)
- (void)tieToRecogniser:(UIGestureRecognizer *)recogniser
{
	Ivar targetsIvar = class_getInstanceVariable(NSClassFromString(@"UIGestureRecognizer"), "_targets");
	id targetActionPairs = object_getIvar(recogniser, targetsIvar);

	Ivar targetIvar = class_getInstanceVariable(NSClassFromString(@"UIGestureRecognizerTarget"), "_target");
	Ivar actionIvar = class_getInstanceVariable(NSClassFromString(@"UIGestureRecognizerTarget"), "_action");

	for (id targetActionPair in targetActionPairs)
	{
    	id target = object_getIvar(targetActionPair, targetIvar);
    	SEL action = (__bridge void *)object_getIvar(targetActionPair, actionIvar);
		[self addTarget:target action:action];
	}
}
@end

@implementation NSValue (CGFrameDimensions)
- (CGFloat)widthOfSizeOfRect { return self.CGRectValue.size.width; }
- (CGFloat)heightOfSizeOfRect { return self.CGRectValue.size.height; }
@end

@interface PopoverNavigationController () <UIGestureRecognizerDelegate>
@property (nonatomic) UIViewController *observedViewController;
@end

@implementation PopoverNavigationController
{
	BOOL _isObserving;
	
	UIPanGestureRecognizer *_myPopGestureRecogniser;
}

#pragma mark - Lifetime

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
	if (! (self = [super initWithRootViewController:rootViewController]))
		return nil;
	
	self.minimumWidth = 160.0f;
	
	self.navigationBarHidden = [self shouldHideNavigationBarWithTopViewController:rootViewController];
#if ! TARGET_OS_TV
	self.toolbarHidden = [self shouldHideToolbarWithTopViewController:rootViewController];
#endif
	self.observedViewController = rootViewController;
	
	_myPopGestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopGesture:)];
	//[_myPopGestureRecogniser tieToRecogniser:self.interactivePopGestureRecogniser];
	_myPopGestureRecogniser.delegate = self;
	
	return self;
}

- (void)dealloc
{
	self.observedViewController = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[UIApplication.sharedApplication.keyWindow addGestureRecognizer:_myPopGestureRecogniser];
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[_myPopGestureRecogniser.view removeGestureRecognizer:_myPopGestureRecogniser];
}


#pragma mark - Key-Value Observing

@synthesize observedViewController=_observedViewController;
- (void)setObservedViewController:(UIViewController *)observedViewController
{
	[_observedViewController removeObserver:self forKeyPath:@"preferredContentSize" context:(__bridge void *)PopoverNavigationController.class];
	if ([_observedViewController respondsToSelector:@selector(hidesNavigationBarWhenPushed)])
		[_observedViewController removeObserver:self forKeyPath:@"hidesNavigationBarWhenPushed" context:(__bridge void *)PopoverNavigationController.class];
	if ([_observedViewController respondsToSelector:@selector(hidesToolbarWhenPushed)])
		[_observedViewController removeObserver:self forKeyPath:@"hidesToolbarWhenPushed" context:(__bridge void *)PopoverNavigationController.class];
	
	_observedViewController = observedViewController;
	
	[_observedViewController addObserver:self forKeyPath:@"preferredContentSize" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)PopoverNavigationController.class];
	if ([_observedViewController respondsToSelector:@selector(hidesNavigationBarWhenPushed)])
		[_observedViewController addObserver:self forKeyPath:@"hidesNavigationBarWhenPushed" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)PopoverNavigationController.class];
	if ([_observedViewController respondsToSelector:@selector(hidesToolbarWhenPushed)])
		[_observedViewController addObserver:self forKeyPath:@"hidesToolbarWhenPushed" options:NSKeyValueObservingOptionNew context:(__bridge void *)PopoverNavigationController.class];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if (context != (__bridge void *)PopoverNavigationController.class)
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	else if ([keyPath isEqualToString:@"preferredContentSize"])
	{
		if (_isObserving) // prevent recursion
			return;
		_isObserving = YES;
		
		CGSize contentSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
		UINavigationItem *navigationItem = [object navigationItem];
		CGSize preferredContentSize = [self idealSizeWithContentSize:contentSize navigationItem:navigationItem];
		
		[self willChangeValueForKey:@"preferredContentSize"];
		[self setPreferredContentSize:preferredContentSize];
		[object setPreferredContentSize:preferredContentSize];
		[self didChangeValueForKey:@"preferredContentSize"];
		[self.view setNeedsLayout];
		
		_isObserving = NO;
	}
	else if ([keyPath isEqualToString:@"hidesNavigationBarWhenPushed"])
	{
		self.navigationBarHidden = [self shouldHideNavigationBarWithTopViewController:object];
		[object setPreferredContentSize:[object preferredContentSize]];
	}
#if ! TARGET_OS_TV
	else if ([keyPath isEqualToString:@"hidesToolbarWhenPushed"])
	{
		self.toolbarHidden = [self shouldHideToolbarWithTopViewController:object];
		[object setPreferredContentSize:[object preferredContentSize]];
	}
#endif
}


#pragma mark - navigationBarHidden & preferredContentSize

- (CGSize)idealSizeWithContentSize:(CGSize)contentSize navigationItem:(UINavigationItem *)navigationItem
{
	if (self.navigationBarHidden)
		return contentSize;
	
	UIFont *titleFont = [UITableViewCell new].textLabel.font; // get the font from a dummy cell (17.0f point)
	CGFloat separatorSpace = 0.5f * self.navigationBar.frame.size.height;
	/*
	CGFloat titleWidth = [navigationItem.title sizeWithAttributes:@{ NSFontAttributeName : cellFont }].width;
	CGFloat navigationItemWidth = MAX(3.0f*self.navigationBar.frame.size.height + titleWidth, self.minimumWidth);
	*/
	NSString *abbreviatedBackButtonTitle = [[navigationItem valueForKey:@"abbreviatedBackButtonTitles"] firstObject];
    
	CGFloat backButtonWidth =
#if ! TARGET_OS_TV
    navigationItem.hidesBackButton? 0.0f : self.navigationBar.backIndicatorImage.size.width + separatorSpace +
#endif
    [abbreviatedBackButtonTitle sizeWithAttributes:@{ NSFontAttributeName : titleFont }].width;
    
	CGFloat leftButtonsWidth = [[navigationItem.leftBarButtonItems valueForKeyPath:@"@sum.view.frame.widthOfSizeOfRect"] floatValue];
	CGFloat titleWidth = [navigationItem.title sizeWithAttributes:@{ NSFontAttributeName : titleFont }].width;
	CGFloat rightButtonsWidth = [[navigationItem.rightBarButtonItems valueForKeyPath:@"@sum.view.frame.widthOfSizeOfRect"] floatValue];

	CGFloat navigationItemWidth = separatorSpace + backButtonWidth + leftButtonsWidth + 2*separatorSpace + titleWidth + 2*separatorSpace + rightButtonsWidth + separatorSpace;
	return CGSizeMake(MAX(MAX(contentSize.width, navigationItemWidth), 100.0f), contentSize.height /* + self.navigationBar.frame.size.height*/);
}

- (BOOL)shouldHideNavigationBarWithTopViewController:(UIViewController *)viewController
{
	if (! [viewController respondsToSelector:@selector(hidesNavigationBarWhenPushed)])
		return NO;
	else
		return viewController.hidesNavigationBarWhenPushed;
}

- (BOOL)shouldHideToolbarWithTopViewController:(UIViewController *)viewController
{
	if (! [viewController respondsToSelector:@selector(hidesToolbarWhenPushed)])
		return YES;
	else
		return viewController.hidesToolbarWhenPushed;
}


#pragma mark - Overridden UINavigationController methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	// refresh navigation bar status and content size
	self.navigationBarHidden = [self shouldHideNavigationBarWithTopViewController:viewController];
#if ! TARGET_OS_TV
	self.toolbarHidden = [self shouldHideToolbarWithTopViewController:viewController];
#endif
	self.observedViewController = viewController;
	
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	if (self.viewControllers.count < 2)
		return [super popViewControllerAnimated:animated];
	
	UIViewController *nextTopViewController = self.viewControllers[self.viewControllers.count-2];
	
	// refresh navigation bar status and content size
	self.navigationBarHidden = [self shouldHideNavigationBarWithTopViewController:nextTopViewController];
#if ! TARGET_OS_TV
	self.toolbarHidden = [self shouldHideToolbarWithTopViewController:nextTopViewController];
#endif
	self.observedViewController = nextTopViewController;
	
	return [super popViewControllerAnimated:animated];
}


#pragma mark - Gesture delegate + target-action handling

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer != _myPopGestureRecogniser)
		return YES;
	
	// reject unless touches began left of (or exactly at) the edge of navigable content
	CGPoint location = [[[gestureRecognizer valueForKey:@"touches"] firstObject] previousLocationInView:nil];
	CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:self.topViewController.view.bounds fromView:self.topViewController.view];
	if (location.x > CGRectGetMinX(frame))
		return NO;
	
	// reject anything but right-pointing gestures
	else if ([_myPopGestureRecogniser velocityInView:_myPopGestureRecogniser.view].x < 10.0f)
		return NO;
	
	else
		return YES;
}

- (IBAction)handlePopGesture:(UIPanGestureRecognizer *)sender
{
	// invoke a non-interactive pop transition
	if (sender.state == UIGestureRecognizerStateBegan)
		[self popViewControllerAnimated:YES];

	/*
	else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
	{
		// restore correct observation target + navigation bar state after an ended or cancelled pop gesture
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
		{
    		self.navigationBarHidden = [self shouldHideNavigationBarWithTopViewController:self.topViewController];
			self.observedViewController = self.topViewController;
		});
	}
	*/
}

@end
