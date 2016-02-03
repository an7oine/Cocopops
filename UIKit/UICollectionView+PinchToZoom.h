//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

// uncomment to enable zooming in response to 3D Touch gestures (buggy)
//#define ENABLE_3D_TOUCH_GESTURE

@interface UICollectionView (PinchToZoom)

/**
Enable Pinch-to-Zoom and Double-Tap-to-Zoom gestures for a collection view. Call only once per view, e.g. from within -[UIViewController viewDidLoad].
@param minimumFactor Minimum (farthest) allowed zoom level, where 1.0f is a 1:1 ratio
@param maximumFactor Maximum (closest) allowed zoom level, which must be @c >= @c self.minimumfactor
 */
- (void)enableZoomGesturesWithMinimumFactor:(CGFloat)minimumFactor maximumFactor:(CGFloat)maximumFactor;

/**
Manually set zoom level to the given number
 */
- (void)setZoomFactor:(CGFloat)zoomFactor animated:(BOOL)animated;

/**
Adjust @c self.contentInset to place content in the middle of self.bounds. Called automatically in response to zoom-related events, but callable also directly from client code, e.g. from -[UIViewController viewWillLayoutSubviews].
 */
- (void)adjustContentInsetToCentreContent;

@end


@interface UICollectionViewLayout (ZoomFactor)

/**
Implement in any custom layout to actually apply the scale adjustment. Implemented here directly for @c UICollectionViewFlowLayout.
@param zoomFactor A (non-cumulative) factor to be applied on top of any existing zoom level, e.g. 2.0 means two times closer compared to the current zoom level.
 */
- (void)applyZoomFactor:(CGFloat)zoomFactor;

@end

@protocol UICollectionViewZoomDelegate <UICollectionViewDelegate>

/**
Implement to react when the zoom level changes.
@param zoomFactor The new level
@param gestureFinished @c YES if the gesture (pinch or double-tap) has finished and no more level changes (animated or user-requested) will occur, @c NO otherwise
 */
- (void)collectionView:(UICollectionView *)collectionView didSetZoomFactor:(CGFloat)zoomFactor gestureFinished:(BOOL)gestureFinished;

@end