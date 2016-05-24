//
//  2014 Magna cum laude. PD
//

#import "AdBannerViewController.h"
#import "InAppPurchaseController.h"

#import <iAd/iAd.h>

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface AdBannerViewController () <ADBannerViewDelegate>
@end

@implementation AdBannerViewController
{
    ADBannerView *_adBanner;
    CGRect _keyboardFrame;
}

@synthesize hideAdvertising=_hideAdvertising, hideAdvertisingIAPProductIdentifier=_hideAdvertisingIAPProductIdentifier;

@synthesize contentController=_contentController;
- (UIViewController *)contentController
{
	if (! _contentController)
        [self performSegueWithIdentifier:SETCONTENT_SEGUE sender:self];
	NSAssert(_contentController, @"AdBannerVC: content VC not set, and performing segue \"" SETCONTENT_SEGUE "\" failed!");
	return _contentController;
}

+ (ADBannerView *)adBanner
{
#if STATIC_BANNER
	static ADBannerView *_adBanner = nil;
    return _adBanner ?: (_adBanner = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner]);
#else
	return [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
#endif
}

- (ADBannerView *)adBanner
{
    if (_adBanner)
        return _adBanner;
    _adBanner = self.class.adBanner;
    _adBanner.delegate = self;
    return _adBanner;
}

- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];

    [self addChildViewController:self.contentController];
    [contentView addSubview:self.contentController.view];
    [self.contentController didMoveToParentViewController:self];

    self.view = contentView;
    _keyboardFrame = CGRectNull;
}

- (void)setHideAdvertisingIAPProductIdentifier:(NSString *)hideAdvertisingIAPProductIdentifier
{
	if (hideAdvertisingIAPProductIdentifier)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAdvertisingWithPurchasedProduct:) name:InAppPurchaseProductPurchased object:nil];
		if ([InAppPurchaseController.sharedController.purchasedProductIdentifiers containsObject:hideAdvertisingIAPProductIdentifier])
			[self setHideAdvertising:YES];
	}
	_hideAdvertisingIAPProductIdentifier = hideAdvertisingIAPProductIdentifier;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.contentController preferredInterfaceOrientationForPresentation];
}
#ifdef __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif
{
    return [self.contentController supportedInterfaceOrientations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (! self.hideAdvertising)
	{
		if (self.builtinBanner)
			[self.view addSubview:self.builtinBanner];
		[self.view addSubview:self.adBanner];
	}
    [self.view setNeedsLayout];

    [self startKeyboardAutoAdjusting];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopKeyboardAutoAdjusting];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_adBanner removeFromSuperview];
	[self.builtinBanner removeFromSuperview];
}

- (void)viewDidLayoutSubviews
{
    CGRect contentFrame = self.view.bounds;
    CGRect builtinBannerFrame = (CGRect) { CGPointZero, [self.builtinBanner sizeThatFits:contentFrame.size] };
	CGRect adBannerFrame = (CGRect) { CGPointZero, [_adBanner sizeThatFits:contentFrame.size] };

	// reserve space for the active banner, if advertising is not explicitly hidden
	if (! self.hideAdvertising)
	{
		if (_adBanner.bannerLoaded)
			contentFrame.size.height -= CGRectGetHeight(adBannerFrame);
		else if (self.builtinBanner)
			contentFrame.size.height -= CGRectGetHeight(builtinBannerFrame);
	}
	
	if (CGRectIsNull(_keyboardFrame))
	{
		// place both banners at bottom of the screen
		builtinBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - builtinBannerFrame.size.height;
    	if (_adBanner.bannerLoaded)
            adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - adBannerFrame.size.height;
		else
        	adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
	}
	else
	{
		// place both banners right above keyboardFrame
		builtinBannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - builtinBannerFrame.size.height;
		if (_adBanner.bannerLoaded)
            adBannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - adBannerFrame.size.height;
		else
        	adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
	}

    // set frame for each subview
	self.builtinBanner.frame = builtinBannerFrame;
    _adBanner.frame = adBannerFrame;
    self.contentController.view.frame = contentFrame;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView animateWithDuration:0.25f animations:^
    {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView animateWithDuration:0.25f animations:^
    {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

- (void)startKeyboardAutoAdjusting
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)stopKeyboardAutoAdjusting
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
	CGRect kbdFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardFrame = [self.view convertRect:kbdFrame fromView:self.view.window];

    NSNumber *animationCurve = aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];

    [UIView animateWithDuration:animationDuration.floatValue delay:0.0f options:animationCurve.integerValue animations:^
    {
		 [self.view setNeedsLayout];
		 [self.view layoutIfNeeded];
    } completion:^(BOOL finished)
	{
	}];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
	_keyboardFrame = CGRectNull;

    NSNumber *animationCurve = aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];

    [UIView animateWithDuration:animationDuration.floatValue delay:0.0f options:animationCurve.integerValue animations:^
	{
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished)
	{
	}];
}

- (void)setHideAdvertising:(BOOL)hideAdvertising
{
	if (! _hideAdvertising && hideAdvertising)
	{
		_hideAdvertising = YES;
	
		ADBannerView *oldAdBanner = _adBanner;
		_adBanner = nil;
		
		[UIView animateWithDuration:0.25f animations:^
		{
			[self.view setNeedsLayout];
			[self.view layoutIfNeeded];
			
			self.builtinBanner.frame = (CGRect){ CGPointMake(0.0f, CGRectGetMaxY(self.contentController.view.frame)), self.builtinBanner.frame.size };
			
			if (oldAdBanner.bannerLoaded)
				oldAdBanner.frame = (CGRect){ CGPointMake(0.0f, CGRectGetMaxY(self.contentController.view.frame)), oldAdBanner.frame.size };
		} completion:^(BOOL finished)
		{
			[oldAdBanner removeFromSuperview];
		}];
	}
	else if (_hideAdvertising && ! hideAdvertising)
	{
		_hideAdvertising = NO;
	
		[self.view addSubview:self.adBanner];
		[self.view setNeedsLayout];
	}
}

- (void)hideAdvertisingWithPurchasedProduct:(NSNotification *)notification
{
	if ([[notification.userInfo valueForKey:@"productIdentifier"] isEqualToString:self.hideAdvertisingIAPProductIdentifier])
		[self setHideAdvertising:YES];
}

@end


@implementation AdBannerContentSegue
- (void)perform
{
    [(AdBannerViewController *)self.sourceViewController setContentController:self.destinationViewController];
}
@end
