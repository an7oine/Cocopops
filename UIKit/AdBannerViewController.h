//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

#define SETCONTENT_SEGUE @"SetContent" // instantiate an AdBannerContentSegue in your Storyboard using this identifier

/**
 A notification identifier, triggered whenever the user taps on a visible advert
 */
extern NSString * const BannerViewActionWillBegin;

/**
 A notification identifier, triggered whenever a user-requested fullscreen advert is hidden
 */
extern NSString * const BannerViewActionDidFinish;

/**
IMPORTANT: you will now need to link against MoPubSDK to use this class. See their instructions at:
 https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started
 
Display an advert banner below user-supplied contentViewController's content whenever an advert is available. Keep the banner hidden otherwise, and display a user-supplied fallback banner if available.

Note that any active @c inputView is always displayed right against the screen edge, and whenever one is in place, the ad banner stays between the @c inputView and @c contentViewController.view

Usage (via Interface Builder):

1. instantiate an @c AdBannerViewController and a desired content @c viewController,

2. set the @c mpUnitID runtime attribute to the Ad Unit ID created using MoPub dashboard,

3. instantiate an @c AdBannerContentSegue from the @c AdBannerViewController to the content @c VC with @c identifier="SetContent"
*/
@interface AdBannerViewController : UIViewController

@property (nonatomic) BOOL hideAdvertising;
@property (nonatomic) NSString *hideAdvertisingIAPProductIdentifier; // if set, monitor purchases with this identifier and hide adverts in response

@property (nonatomic, strong) UIViewController *contentController;
@property (nonatomic, strong) IBOutlet UIView *builtinBanner; // assign a fallback view to display whenever an advert fails to load

@property (nonatomic) NSString *mpUnitID; // Ad unit ID, assigned by the MoPub network (enter e.g. via IB as a user defined runtime attribute)

@end

/**
A custom placeholder segue linking an AdBannerViewController to its user-supplied content. Will be automatically triggered once the associated AdBannerViewController instance becomes visible.
 */
@interface AdBannerContentSegue : UIStoryboardSegue
@end
