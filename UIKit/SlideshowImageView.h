//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface SlideshowImageView : UIImageView

@property (nonatomic, readonly) BOOL isAnimatingTransitions;
@property (nonatomic) UIViewAnimationOptions animatedTransitionOptions;
@property (nonatomic) CGFloat animatedTransitionDuration;

@end
