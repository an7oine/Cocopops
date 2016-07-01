//
//  2014 Magna cum laude. PD
//

#import "AdBannerViewController.h"
#import "InAppPurchaseController.h"

#import "MPAdView.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface AdBannerViewController ()
@property (nonatomic, readonly) UIView *adView;
@property (nonatomic, readonly) BOOL adViewHasContent;
@end

@interface AdBannerViewController () <MPAdViewDelegate> @end

@implementation AdBannerViewController
{
	MPAdView *_adContentView;
	UIView *_adContainerView;
	
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
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
			// place either banner at bottom of the screen, hide the other
			if (self.adViewHasContent)
			{
				builtinBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
				adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - adBannerFrame.size.height;
			}
			else
			{
				builtinBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds) - builtinBannerFrame.size.height;
				adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
			}
		}
		else
		{
			// place either banner right above keyboardFrame, hide the other
			if (self.adViewHasContent)
			{
				builtinBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
				adBannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - adBannerFrame.size.height;
			}
			else
			{
				builtinBannerFrame.origin.y = CGRectGetMinY(_keyboardFrame) - builtinBannerFrame.size.height;
				adBannerFrame.origin.y = CGRectGetMaxY(self.view.bounds);
			}
		}
	}
	else
		// hide both banners
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

- (UIView *)adView
{
    if (_adContainerView)
        return _adContainerView;
	
    _adContentView = [[MPAdView alloc] initWithAdUnitId:self.mpUnitID size:MOPUB_BANNER_SIZE];
    _adContentView.delegate = self;
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

@end


@implementation AdBannerContentSegue
- (void)perform
{
    [(AdBannerViewController *)self.sourceViewController setContentController:self.destinationViewController];
}
@end
