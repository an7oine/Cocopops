//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

/**
Define as 1 for the iAd network, 0 for MoPub

Note that to use iAd, you will need to link against iAd.framework

For MoPub, see their instructions at:
https://github.com/mopub/mopub-ios-sdk/wiki/Banner-Integration-For-iOS
 */
#define USE_IAD 0

#define SETCONTENT_SEGUE @"SetContent" // instantiate an AdBannerContentSegue in your Storyboard using this identifier

extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;

/**
Display an advert banner below user-supplied contentViewController's content whenever an advert is available, and keep the banner hidden otherwise.

Note that any active @c inputView is always displayed right on the screen edge, and whenever one is in place, the ad banner stays between the @c inputView and @c contentViewController.view

Usage:

1. instantiate an @c AdBannerViewController and a desired content @c viewController in IB,

2. instantiate an @c AdBannerContentSegue in IB with @c src=adBannerVC, @c dest=contentVC, @c identifier="SetContent"
*/
@interface AdBannerViewController : UIViewController

@property (nonatomic) BOOL hideAdvertising;
@property (nonatomic) NSString *hideAdvertisingIAPProductIdentifier; // if set, monitor purchases with this identifier and hide adverts in response

@property (nonatomic, strong) UIViewController *contentController;
@property (nonatomic, strong) IBOutlet UIView *builtinBanner; // assign a fallback view to display whenever an advert fails to load

@property (nonatomic) NSString *mpUnitID; // Ad unit ID assigned by the MoPub network (not used by iAd)

@end

@interface AdBannerContentSegue : UIStoryboardSegue
@end