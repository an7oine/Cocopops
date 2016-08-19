//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "UICollectionView+PinchToZoom.h"
#import "TwoDimensionalLayout.h"

@interface ZoomFactors : NSObject
@property (nonatomic) CGFloat min, max, current;
@property (nonatomic) BOOL centreAutomatically;
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

@interface CollectionZoomPinchGestureRecognizer :
#if TARGET_OS_TV
UIGestureRecognizer
#else
UIPinchGestureRecognizer
#endif
@property (nonatomic) ZoomFactors *factors;
@end
@implementation CollectionZoomPinchGestureRecognizer
@end

@interface CollectionZoomTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic) ZoomFactors *factors;
@end
@implementation CollectionZoomTapGestureRecognizer
@end

#if __IPHONE_9_0
@interface CollectionZoomForceTouchGestureRecognizer : UIGestureRecognizer
@property (nonatomic) ZoomFactors *factors;
@property (nonatomic) CGFloat threshold;
@property (nonatomic) CGFloat originalLevel;
@property (nonatomic) CGFloat scale;
@end
@implementation CollectionZoomForceTouchGestureRecognizer
- (void)respondToTouch:(UITouch *)touch
{
	if (self.state == UIGestureRecognizerStatePossible && touch.force >= self.threshold * touch.maximumPossibleForce)
	{
		//self.scale = touch.force / touch.maximumPossibleForce;
		self.state = UIGestureRecognizerStateBegan;
	}
	else if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged)
	{
		self.scale = touch.force / touch.maximumPossibleForce;
		self.state = UIGestureRecognizerStateChanged;
	}
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStatePossible;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[self respondToTouch:touches.anyObject];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.state = UIGestureRecognizerStateFailed;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateChanged)
        self.state = UIGestureRecognizerStateRecognized;
    else
        self.state = UIGestureRecognizerStateCancelled;
}
@end
#endif

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

@interface UICollectionView () <UIGestureRecognizerDelegate> @end

@implementation UICollectionView (PinchToZoom)

- (void)enableZoomGesturesWithMinimumFactor:(CGFloat)minimumFactor maximumFactor:(CGFloat)maximumFactor centreAutomatically:(BOOL)centreAutomatically
{
	ZoomFactors *factors = [[ZoomFactors alloc] initWithMinimum:minimumFactor maximum:maximumFactor];
	factors.centreAutomatically = centreAutomatically;

#if ! TARGET_OS_TV
	CollectionZoomPinchGestureRecognizer *pinchRecognizer = [[CollectionZoomPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gotPinchToZoomGesture:)];
	[self addGestureRecognizer:pinchRecognizer];
	pinchRecognizer.factors = factors;
	pinchRecognizer.delegate = self;

    CollectionZoomTapGestureRecognizer *doubleTapRecognizer = [[CollectionZoomTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotDoubleTapGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.delaysTouchesBegan = YES;
    [self addGestureRecognizer:doubleTapRecognizer];
	doubleTapRecognizer.factors = factors;
#endif
	
#ifdef ENABLE_3D_TOUCH_GESTURE
	if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
	{
		CollectionZoomForceTouchGestureRecognizer *forceTouchRecognizer = [[CollectionZoomForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(gotForceTouchGesture:)];
		forceTouchRecognizer.threshold = 0.75f;
		[self addGestureRecognizer:forceTouchRecognizer];
		forceTouchRecognizer.factors = factors;
	}
#endif

	NSAssert(minimumFactor <= maximumFactor, @"Invalid zoom limits: [%.3f %.3f] ", minimumFactor, maximumFactor);
	if (minimumFactor > 1.0f)
	{
		[self.collectionViewLayout applyZoomFactor:minimumFactor];
		if (factors.centreAutomatically)
			[self adjustContentInsetToCentreContent];
		
		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didApplyZoomFactor:minimumFactor toLevel:minimumFactor gestureFinished:YES];
	}
	else if (maximumFactor < 1.0f)
	{
		[self.collectionViewLayout applyZoomFactor:maximumFactor];
		if (factors.centreAutomatically)
			[self adjustContentInsetToCentreContent];
		
		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didApplyZoomFactor:maximumFactor toLevel:maximumFactor gestureFinished:YES];
	}
}


#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return otherGestureRecognizer == self.panGestureRecognizer;
}


#pragma mark - Zoom factor property

- (CGFloat)zoomFactor
{
	ZoomFactors *factors = nil;
	for (CollectionZoomPinchGestureRecognizer *gestureRecogniser in self.gestureRecognizers)
		if ([gestureRecogniser isKindOfClass:CollectionZoomPinchGestureRecognizer.class])
			factors = gestureRecogniser.factors;
	if (factors)
		return factors.current;
	else
		return 1.0f;
}
- (void)setZoomFactor:(CGFloat)zoomFactor animated:(BOOL)animated
{
	ZoomFactors *factors = nil;
	for (CollectionZoomPinchGestureRecognizer *gestureRecogniser in self.gestureRecognizers)
		if ([gestureRecogniser isKindOfClass:CollectionZoomPinchGestureRecognizer.class])
			factors = gestureRecogniser.factors;
	if (factors)
		[self setZoomLevel:zoomFactor aroundPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) withFactors:factors animated:animated finished:YES];
}


#pragma mark - Action targets

- (IBAction)gotPinchToZoomGesture:(CollectionZoomPinchGestureRecognizer *)sender
{
#if ! TARGET_OS_TV
	// start from the current zoom level
	if (sender.state == UIGestureRecognizerStateBegan)
		sender.scale *= sender.factors.current;

	// get scale of the gesture
	CGFloat level = sender.scale;
	
	// clip against client-defined upper and lower zoom level bounds
	CGFloat clippedLevel = MIN( MAX(level, sender.factors.min), sender.factors.max );
	if (level != clippedLevel)
	{
		// replace the gesture-proposed out-of-spec zoom level with geometric mean (rubber band effect)
		level = sqrt(sender.scale * clippedLevel);
	}
	
	// assign the current level
	CGFloat oldLevel = sender.factors.current;
	[self setZoomLevel:level aroundPoint:[sender locationInView:self] withFactors:sender.factors animated:NO finished:NO];

	if (sender.state == UIGestureRecognizerStateEnded)
	{
		// animate a zoom back within the bounds, if necessary
		if (clippedLevel != sender.factors.current)
        	[self setZoomLevel:clippedLevel aroundPoint:[sender locationInView:self] withFactors:sender.factors animated:YES finished:YES];
		
		// otherwise, just inform the delegate
		else if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didApplyZoomFactor:sender.factors.current/oldLevel toLevel:sender.factors.current gestureFinished:YES];
	}
#endif
}

- (IBAction)gotDoubleTapGesture:(CollectionZoomTapGestureRecognizer *)sender
{
    CGFloat targetLevel = sender.factors.current / sender.factors.max > sender.factors.min / sender.factors.current? sender.factors.min : sender.factors.max;
	NSAssert(sender.factors.current != 0.0f, @"Invalid current zoom factor: sender.factors == %@", sender.factors);
    
	[self setZoomLevel:targetLevel aroundPoint:[sender locationInView:self] withFactors:sender.factors animated:YES finished:YES];
}

#if __IPHONE_9_0
- (IBAction)gotForceTouchGesture:(CollectionZoomForceTouchGestureRecognizer *)sender
{
	// get location of the gesture
	CGFloat level = sender.scale*sender.scale*sender.scale * sender.factors.max * 1.1f;

	if (sender.state == UIGestureRecognizerStateBegan)
	{
		sender.originalLevel = sender.factors.current;
		
		if (level > sender.originalLevel)
			[self setZoomLevel:level aroundPoint:[sender locationInView:self] withFactors:sender.factors animated:YES finished:NO];
	}
	else if (sender.state == UIGestureRecognizerStateChanged)
	{
		// clip against client-defined upper and lower zoom level bounds
		CGFloat clippedLevel = MIN( MAX(level, sender.factors.min), sender.factors.max );
		if (level != clippedLevel)
		{
			// replace the gesture-proposed out-of-spec zoom level with geometric mean (rubber band effect)
			level = sqrt(sender.scale * clippedLevel);
		}

		if (level > sender.originalLevel)
			[self setZoomLevel:level aroundPoint:[sender locationInView:self] withFactors:sender.factors animated:NO finished:NO];
	}
	else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled)
	{
		[self setZoomLevel:sender.originalLevel aroundPoint:[sender locationInView:self] withFactors:sender.factors animated:YES finished:YES];
	}
}
#endif


#pragma mark - Helpers

- (void)adjustContentInsetToCentreContent
{
	UIEdgeInsets inset = self.contentInset;
	
	CGFloat horizontalInset = MAX(0.0f, self.bounds.size.width - self.contentSize.width);
	inset.left = 0.5f * horizontalInset;
	inset.right = 0.5f * horizontalInset;
	
	CGFloat verticalInset = MAX(0.0f, self.bounds.size.height - self.contentSize.height - (self.scrollIndicatorInsets.top + self.scrollIndicatorInsets.bottom));
	inset.top = self.scrollIndicatorInsets.top + 0.5f * verticalInset;
	inset.bottom = self.scrollIndicatorInsets.bottom + 0.5f * verticalInset;
	
	self.contentInset = inset;
}

- (void)adjustContentOffsetForFocusPoint:(CGPoint)point factor:(CGFloat)factor
{
	CGPoint touchOffset = CGPointMake(point.x - self.contentOffset.x, point.y - self.contentOffset.y);
	point.x *= factor;
	point.y *= factor;
	self.contentOffset = CGPointMake(point.x - touchOffset.x, point.y - touchOffset.y);
}

- (CGPoint)setZoomLevel:(CGFloat)level aroundPoint:(CGPoint)point withFactors:(ZoomFactors *)factors animated:(BOOL)animated finished:(BOOL)finished
{
    CGFloat factor = level / factors.current;
	factors.current = level;

	if (animated)
	{
		CGAffineTransform originalTransform = self.transform;
		
		CGPoint translationPoint = CGPointMake(point.x - self.contentOffset.x - 0.5f*self.frame.size.width, point.y - self.contentOffset.y - 0.5f*self.frame.size.height);
		CGAffineTransform transitionalTransform = CGAffineTransformMakeTranslation(-translationPoint.x, -translationPoint.y);
		transitionalTransform = CGAffineTransformConcat(transitionalTransform, CGAffineTransformMakeScale(factor, factor));
		transitionalTransform = CGAffineTransformConcat(transitionalTransform, CGAffineTransformMakeTranslation(translationPoint.x, translationPoint.y));

		[UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^
		{
			self.transform = transitionalTransform;
		} completion:^(BOOL finished)
		{
			self.transform = originalTransform;
			[self.collectionViewLayout applyZoomFactor:factor];
			[self adjustContentOffsetForFocusPoint:point factor:factor];
			
			dispatch_async(dispatch_get_main_queue(), ^
			{
				if (factors.centreAutomatically)
					[self adjustContentInsetToCentreContent];

				if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
					[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didApplyZoomFactor:factor toLevel:level gestureFinished:finished];
			});
		}];
	}
	else
	{
		[self.collectionViewLayout applyZoomFactor:factor];
		[self adjustContentOffsetForFocusPoint:point factor:factor];
		if (factors.centreAutomatically)
			[self adjustContentInsetToCentreContent];
		
		if ([self.delegate conformsToProtocol:@protocol(UICollectionViewZoomDelegate)])
			[(id <UICollectionViewZoomDelegate>)self.delegate collectionView:self didApplyZoomFactor:factor toLevel:level gestureFinished:finished];
	}
	
	return CGPointMake(point.x * factor, point.y * factor);
}

@end

