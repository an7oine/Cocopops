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
- (NSString *)description { return [NSString stringWithFormat:@"[%.1f (%.1f) %.1f]", self.min, self.current, self.max]; }
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
    doubleTapRecognizer.delaysTouchesBegan = YES;
    [self addGestureRecognizer:doubleTapRecognizer];

	pinchRecognizer.factors = doubleTapRecognizer.factors = [[ZoomFactors alloc] initWithMinimum:minimumFactor maximum:maximumFactor];

	NSAssert(minimumFactor <= maximumFactor, @"Invalid zoom limits: [%.3f %.3f] ", minimumFactor, maximumFactor);
	if (minimumFactor > 1.0f)
	{
		[self.collectionViewLayout applyZoomFactor:minimumFactor];
		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didSetZoomFactor:minimumFactor gestureFinished:YES];
	}
	else if (maximumFactor < 1.0f)
	{
		[self.collectionViewLayout applyZoomFactor:maximumFactor];
		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didSetZoomFactor:maximumFactor gestureFinished:YES];
	}
}

- (void)adjustContentOffsetForFocusPoint:(CGPoint)point factor:(CGFloat)factor
{
    CGPoint touchOffset = CGPointMake(point.x - self.contentOffset.x, point.y - self.contentOffset.y);
    point.x *= factor;
    point.y *= factor;
    self.contentOffset = CGPointMake(point.x - touchOffset.x, point.y - touchOffset.y);
}

- (void)animateZoomByFactor:(CGFloat)factor targetLevel:(CGFloat)targetLevel aroundPoint:(CGPoint)point
{
    CGAffineTransform originalTransform = self.transform;

	CGPoint translationPoint = CGPointMake(point.x - self.contentOffset.x - 0.5f*self.frame.size.width, point.y - self.contentOffset.y - 0.5f*self.frame.size.height);
	CGAffineTransform targetTransform = CGAffineTransformMakeTranslation(-translationPoint.x, -translationPoint.y);
	targetTransform = CGAffineTransformConcat(targetTransform, CGAffineTransformMakeScale(factor, factor));
	targetTransform = CGAffineTransformConcat(targetTransform, CGAffineTransformMakeTranslation(translationPoint.x, translationPoint.y));

	[UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
		self.transform = targetTransform;
    } completion:^(BOOL finished)
    {
    	self.transform = originalTransform;
    	[self.collectionViewLayout applyZoomFactor:factor];
		[self adjustContentOffsetForFocusPoint:point factor:factor];

		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didSetZoomFactor:targetLevel gestureFinished:YES];
    }];
}

- (IBAction)gotPinchToZoomGesture:(CollectionZoomPinchGestureRecognizer *)sender
{
	// when the gesture starts, assign the current zoom level into it
	if (sender.state == UIGestureRecognizerStateBegan)
		sender.scale *= sender.factors.current;

	// get location of the gesture
	CGPoint focusPoint = [sender locationInView:self];

	// get the new (cumulative) zoom level proposed by the gesture
	CGFloat newFactor = sender.scale;
	
	// validate that zoom level against client-defined upper and lower bounds
	CGFloat clippedFactor = MIN( MAX(newFactor, sender.factors.min), sender.factors.max );
	if (newFactor != clippedFactor)
	{
		// replace the gesture-proposed new zoom level with geometric mean
		newFactor = sqrt(sender.scale * clippedFactor);
	}
	
	// calculate the incremental adjustment needed to the collectionViewLayout and contentOffset
	CGFloat transition = newFactor / sender.factors.current;
	
	// set as current, then apply
	sender.factors.current = newFactor;
    [self.collectionViewLayout applyZoomFactor:transition];
    [self adjustContentOffsetForFocusPoint:focusPoint factor:transition];

	// after the gesture has ended, clip back within the bounds if necessary
	if (sender.state == UIGestureRecognizerStateEnded && clippedFactor != sender.factors.current)
	{
		// inform the delegate, but act as if the gesture was still active
		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didSetZoomFactor:sender.factors.current gestureFinished:NO];
		
		// then animate a zoom back within the bounds
		CGFloat clipToBounds = clippedFactor / sender.factors.current;
		
        sender.factors.current = clippedFactor;
        [self animateZoomByFactor:clipToBounds targetLevel:clippedFactor aroundPoint:focusPoint];
	}
	
	// otherwise (if the gesture is still active, or it has finished within the designated bounds), just inform the delegate
	else if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
		[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didSetZoomFactor:sender.factors.current gestureFinished:(sender.state == UIGestureRecognizerStateEnded)];
}

- (IBAction)gotDoubleTapGesture:(CollectionZoomTapGestureRecognizer *)sender
{
    CGFloat targetLevel = sender.factors.current / sender.factors.max > sender.factors.min / sender.factors.current? sender.factors.min : sender.factors.max;
	NSAssert(sender.factors.current != 0.0f, @"Invalid current zoom factor: sender.factors == %@", sender.factors);
    
    CGFloat factor = targetLevel / sender.factors.current;
    CGPoint point = [sender locationInView:self];
    
	sender.factors.current = targetLevel;
    [self animateZoomByFactor:factor targetLevel:targetLevel aroundPoint:point];
}

@end
