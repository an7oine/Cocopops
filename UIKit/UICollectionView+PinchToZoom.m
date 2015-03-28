//
//  2014 Magna cum laude. PD
//

#import "UICollectionView+PinchToZoom.h"
#import "TwoDimensionalLayout.h"

@interface ZoomFactors : NSObject
@property (nonatomic) CGFloat min, max, current;
@end
@implementation ZoomFactors
- (instancetype)initWithMinimum:(CGFloat)min maximum:(CGFloat)max
{
	self = [super init];
	self.min = min;
	self.max = max;
	self.current = MIN( MAX(1.0f, min), max);
	return self;
}
@end

@interface CollectionZoomPinchGestureRecognizer : UIPinchGestureRecognizer
@property (nonatomic) ZoomFactors *factors;
@end
@implementation CollectionZoomPinchGestureRecognizer
@end

@interface CollectionZoomTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic) ZoomFactors *factors;
@end
@implementation CollectionZoomTapGestureRecognizer
@end


@implementation UICollectionViewFlowLayout (ZoomFactor)
- (void)applyZoomFactor:(CGFloat)zoomFactor
{
    self.itemSize = CGSizeMake(self.itemSize.width * zoomFactor, self.itemSize.height * zoomFactor);
    self.minimumInteritemSpacing *= zoomFactor;
    self.minimumLineSpacing *= zoomFactor;
    self.headerReferenceSize = CGSizeMake(self.headerReferenceSize.width * zoomFactor, self.headerReferenceSize.height * zoomFactor);
    self.footerReferenceSize = CGSizeMake(self.footerReferenceSize.width * zoomFactor, self.footerReferenceSize.height * zoomFactor);
}
@end


@implementation UICollectionView (PinchToZoom)

- (void)enableZoomGesturesWithMinimumFactor:(CGFloat)minimumFactor maximumFactor:(CGFloat)maximumFactor
{
	CollectionZoomPinchGestureRecognizer *pinchRecognizer = [[CollectionZoomPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gotPinchToZoomGesture:)];
	[self addGestureRecognizer:pinchRecognizer];

    CollectionZoomTapGestureRecognizer *doubleTapRecognizer = [[CollectionZoomTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotDoubleTapGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapRecognizer];

	pinchRecognizer.factors = doubleTapRecognizer.factors = [[ZoomFactors alloc] initWithMinimum:minimumFactor maximum:maximumFactor];

	if (minimumFactor > 1.0f)
	{
		[self.collectionViewLayout applyZoomFactor:minimumFactor];
		[self.visibleCells makeObjectsPerformSelector:@selector(setNeedsDisplay)];
	}
	else if (maximumFactor < 1.0f)
	{
		[self.collectionViewLayout applyZoomFactor:maximumFactor];
		[self.visibleCells makeObjectsPerformSelector:@selector(setNeedsDisplay)];
	}
}

- (void)adjustContentOffsetForFocusPoint:(CGPoint)point factor:(CGFloat)factor
{
    CGPoint touchOffset = CGPointMake(point.x - self.contentOffset.x, point.y - self.contentOffset.y);
    point.x *= factor;
    point.y *= factor;
    self.contentOffset = CGPointMake(point.x - touchOffset.x, point.y - touchOffset.y);
}

- (IBAction)gotPinchToZoomGesture:(CollectionZoomPinchGestureRecognizer *)sender
{
	// clip gesture-originating target zoom factor to min, max limits
	CGFloat factor = MIN( MAX(sender.scale, sender.factors.min / sender.factors.current), sender.factors.max / sender.factors.current );
	sender.factors.current *= factor;

	CGPoint focusPoint = [sender locationInView:self];

    [self.collectionViewLayout applyZoomFactor:factor];
    [self adjustContentOffsetForFocusPoint:focusPoint factor:factor];

	// redraw cell contents only once after the gesture ends
    if (sender.state == UIGestureRecognizerStateEnded)
        [self.visibleCells makeObjectsPerformSelector:@selector(setNeedsDisplay)];

	// reset gesture scale each time it is applied to the content
	sender.scale = 1;
}

- (IBAction)gotDoubleTapGesture:(CollectionZoomTapGestureRecognizer *)sender
{
    CGFloat targetFactor = sender.factors.current / sender.factors.max > 0.75f? sender.factors.min : sender.factors.max;
    CGFloat factor = targetFactor / sender.factors.current;
	sender.factors.current = targetFactor;

    CGPoint focusPoint = [sender locationInView:self];

    CGAffineTransform originalTransform = self.transform;

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
		self.transform = CGAffineTransformMakeScale(factor, factor);
    } completion:^(BOOL finished)
    {
    	self.transform = originalTransform;
    	[self.collectionViewLayout applyZoomFactor:factor];
		[self adjustContentOffsetForFocusPoint:focusPoint factor:factor];
    	[self.visibleCells makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }];
}

@end
