//
//  2014 Magna cum laude. PD
//

#import "AdBannerViewController.h"
#import "InAppPurchaseController.h"

#if USE_IAD
#import <iAd/iAd.h>
#else
#import "MPAdView.h"
#endif

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface AdBannerViewController ()
@property (nonatomic, readonly) UIView *adView;
@property (nonatomic, readonly) BOOL adViewHasContent;
@end

#if USE_IAD
@interface AdBannerViewController () <ADBannerViewDelegate> @end
#else
@interface AdBannerViewController () <MPAdViewDelegate> @end
#endif

@implementation AdBannerViewController
{
#if USE_IAD
    ADBannerView *_adView;
#else
	MPAdView *_adContentView;
	UIView *_adContainerView;
#endif
	
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
			dispatch_async(dispatch_get_main_queue(), ^
			{
				[self setHideAdvertising:YES];
			});
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
		[self.view addSubview:self.adView];
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
    [self.adViewIfLoaded removeFromSuperview];
	[self.builtinBanner removeFromSuperview];
}

- (void)viewDidLayoutSubviews
{
    CGRect contentFrame = self.view.bounds;
    CGRect builtinBannerFrame = (CGRect) { CGPointZero, [self.builtinBanner sizeThatFits:contentFrame.size] };
	CGRect adBannerFrame = (CGRect) { CGPointZero, [self adViewSizeWithProposedSize:contentFrame.size] };

	//builtinBannerFrame.size.width = adBannerFrame.size.width = contentFrame.size.width;

	// reserve space for the active banner, if advertising is not explicitly hidden
	if (! self.hideAdvertising)
	{
		if (self.adViewHasContent)
			contentFrame.size.height -= CGRectGetHeight(adBannerFrame);
		else if (self.builtinBanner)
			contentFrame.size.height -= CGRectGetHeight(builtinBannerFrame);

		if (CGRectIsNull(_keyboardFrame))
		{
			// place both banners at bottom of the screen
			builtinBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - builtinBannerFrame.size.height;

			if (self.adViewHasContent)
				adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - adBannerFrame.size.height;
			else
				adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
		}
		else
		{
			// place both banners right above keyboardFrame
			builtinBannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - builtinBannerFrame.size.height;

			if (self.adViewHasContent)
				adBannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - adBannerFrame.size.height;
			else
				adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
		}
	}
	else
		builtinBannerFrame.origin.y = adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);

    // set frame for each subview
	self.builtinBanner.frame = builtinBannerFrame;
    self.adViewIfLoaded.frame = adBannerFrame;
    self.contentController.view.frame = contentFrame;
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

- (void)keyboardWillShow:(NSNotification *)aNotification
{
	CGRect kbdFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardFrame = [self.view convertRect:kbdFrame fromView:self.view.window];

    NSNumber *animationCurve = aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];

    [UIView animateWithDuration:animationDuration.floatValue delay:0.0f options:animationCurve.integerValue animations:^
    {
		 [self.view setNeedsLayout];
		 [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	_keyboardFrame = CGRectNull;

    NSNumber *animationCurve = aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];

    [UIView animateWithDuration:animationDuration.floatValue delay:0.0f options:animationCurve.integerValue animations:^
	{
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	} completion:nil];
}

- (void)setHideAdvertising:(BOOL)hideAdvertising
{
	if (! _hideAdvertising && hideAdvertising)
	{
		_hideAdvertising = YES;
	
		BOOL adViewHadContent = self.adViewHasContent;
		UIView *oldAdBanner = self.adViewIfLoaded;
		[self destroyAdView];
		
		[UIView animateWithDuration:0.25f animations:^
		{
			[self.view setNeedsLayout];
			[self.view layoutIfNeeded];
			
			self.builtinBanner.frame = (CGRect){ CGPointMake(0.0f, CGRectGetMaxY(self.contentController.view.frame)), self.builtinBanner.frame.size };
			
			if (adViewHadContent)
				oldAdBanner.frame = (CGRect){ CGPointMake(0.0f, CGRectGetMaxY(self.contentController.view.frame)), oldAdBanner.frame.size };
		} completion:^(BOOL finished)
		{
			[oldAdBanner removeFromSuperview];
		}];
	}
	else if (_hideAdvertising && ! hideAdvertising)
	{
		_hideAdvertising = NO;
	
		[self.view addSubview:self.adView];
		[self.view setNeedsLayout];
	}
}

- (void)hideAdvertisingWithPurchasedProduct:(NSNotification *)notification
{
	if ([[notification.userInfo valueForKey:@"productIdentifier"] isEqualToString:self.hideAdvertisingIAPProductIdentifier])
		[self setHideAdvertising:YES];
}


#pragma mark - MoPub

#if ! USE_IAD
- (UIView *)adView
{
    if (_adContainerView)
        return _adContainerView;
	
    _adContentView = [[MPAdView alloc] initWithAdUnitId:self.mpUnitID size:MOPUB_BANNER_SIZE];
    _adContentView.delegate = self;
#ifdef DEBUG
	//__adContentView.testing = YES;
#endif
	[_adContentView loadAd];
	
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
	containerView.backgroundColor = UIColor.whiteColor;
	containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	_adContentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[containerView addSubview:_adContentView];
	
	return _adContainerView = containerView;
}
- (UIView *)adViewIfLoaded { return _adContainerView; }
- (void)destroyAdView
{
	[_adContentView removeFromSuperview];
	[_adContainerView removeFromSuperview];
	_adContentView.delegate = nil, _adContentView = nil, _adContainerView = nil;
	_adViewHasContent = NO;
}
@synthesize adViewHasContent=_adViewHasContent;
- (CGSize)adViewSizeWithProposedSize:(CGSize)size { return CGSizeMake(size.width, [_adContentView adContentViewSize].height); }

- (void)adViewDidLoadAd:(MPAdView *)view
{
	_adViewHasContent = YES;
	[UIView animateWithDuration:0.25f animations:^
    {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}
- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
	_adViewHasContent = NO;
	[UIView animateWithDuration:0.25f animations:^
    {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}
- (void)willPresentModalViewForAd:(MPAdView *)view
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
}
- (void)didDismissModalViewForAd:(MPAdView *)view
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}
- (UIViewController *)viewControllerForPresentingModalView { return self; }

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[_adContentView rotateToOrientation:toInterfaceOrientation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[UIView animateWithDuration:0.25f animations:^
    {
		[self.view setNeedsLayout];
		[self.view layoutIfNeeded];
	}];
}
#endif


#pragma mark - iAd

#if USE_IAD
- (ADBannerView *)adView
{
    if (_adView)
        return _adView;
    _adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _adView.delegate = self;
    return _adView;
}
- (ADBannerView *)adViewIfLoaded { return _adView; }
- (void)destroyAdView { _adView = nil; }
- (BOOL)adViewHasContent { return self.adViewIfLoaded.bannerLoaded; }
- (CGSize)adViewSizeWithProposedSize:(CGSize)size { return [self.adViewIfLoaded sizeThatFits:size]; }

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
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}
#endif

@end


@implementation AdBannerContentSegue
- (void)perform
{
    [(AdBannerViewController *)self.sourceViewController setContentController:self.destinationViewController];
}
@end
