//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

#define STATIC_BANNER 0

extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;

// Display an ADBannerView below user-supplied ContentViewController's content
// whenever an Advert is available, and keep the banner hidden otherwise;
// note that any active InputView is always displayed right on the screen edge,
// and whenever one is in place, the ADBanner stays between the InputView and ContentView

// Usage:
// 1. instantiate AdBannerVC and a desired ContentVC in IB,
// 2. instantiate AdBannerContentSegue in IB with src=adBannerVC, dest=contentVC,
// 3. do [adBannerVC performSegueWithIdentifier:@"MySegueIdentifier" sender:nil] in code

@interface AdBannerViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIViewController *contentController;
@end

@interface AdBannerContentSegue : UIStoryboardSegue
@end