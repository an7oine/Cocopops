//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

// Invoke the enabler in your -viewDidLoad to insert zoom-in/zoom-out gesture recognizers
@interface UICollectionView (PinchToZoom)
- (void)enableZoomGesturesWithMinimumFactor:(CGFloat)minimumFactor maximumFactor:(CGFloat)maximumFactor;
@end

// Make sure to implement these in any of your custom Layouts;
// implementation is provided here for UICollectionViewFlowLayout
// by way of adjusting Cell Size & Spacing + Header & Footer Reference sizes
@interface UICollectionViewLayout (ZoomFactor)
- (void)applyZoomFactor:(CGFloat)zoomFactor; // multiply current factor by this one
@end
