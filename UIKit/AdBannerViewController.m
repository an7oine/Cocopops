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
    if (! self.contentController)
        [self performSegueWithIdentifier:SETCONTENT_SEGUE sender:self];

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
- (NSUInteger)supportedInterfaceOrientations
{
    return [self.contentController supportedInterfaceOrientations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (! self.hideAdvertising)
		[self.view addSubview:self.adBanner];
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
}

- (void)viewDidLayoutSubviews
{
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = (CGRect) { CGPointZero, [_adBanner sizeThatFits:contentFrame.size] };

    // Check if the banner has an ad loaded and ready for display
    if (_adBanner.bannerLoaded)
    {
        contentFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(bannerFrame);
        // place banner below contentFrame
        if (CGRectIsNull(_keyboardFrame))
            bannerFrame.origin.y = CGRectGetMaxY(contentFrame);
        else
            bannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - bannerFrame.size.height;
    }
    else
    {
        contentFrame.size.height = CGRectGetHeight(self.view.bounds);

        // place banner below bottom of the screen
        bannerFrame.origin.y = CGRectGetMaxY(contentFrame);
    }

    // adjust both subviews' frames as necessary
    _adBanner.frame = bannerFrame;

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
    } completion:^(BOOL finished)
	{
		 [self.view setNeedsLayout];
		 [self.view layoutIfNeeded];
	}];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
	_keyboardFrame = CGRectNull;

    NSNumber *animationCurve = aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];

    [UIView animateWithDuration:animationDuration.floatValue delay:0.0f options:animationCurve.integerValue animations:^
	{
	} completion:^(BOOL finished)
	{
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	}];
}

- (void)setHideAdvertising:(BOOL)hideAdvertising
{
	if (! _hideAdvertising && hideAdvertising)
	{
		ADBannerView *oldAdBanner = _adBanner;
		_adBanner = nil;
		
		if (oldAdBanner.bannerLoaded)
			[UIView animateWithDuration:0.25f animations:^
			{
				[self.view setNeedsLayout];
				[self.view layoutIfNeeded];
				oldAdBanner.frame = (CGRect){ CGPointMake(0.0f, CGRectGetMaxY(self.contentController.view.frame)), oldAdBanner.frame.size };
			} completion:^(BOOL finished)
			{
				[oldAdBanner removeFromSuperview];
			}];
		else
			[oldAdBanner removeFromSuperview];
	}
	else if (_hideAdvertising && ! hideAdvertising)
	{
		[self.view addSubview:self.adBanner];
		[self.view setNeedsLayout];
	}
	_hideAdvertising = hideAdvertising;
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
