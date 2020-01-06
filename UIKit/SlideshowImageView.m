//
//  2015 Magna cum laude. PD
//

#import "SlideshowImageView.h"

@implementation SlideshowImageView
{
	__weak NSTimer *_transitionTimer;
	NSInteger _currentImageIndex;
}

@synthesize isAnimatingTransitions=_isAnimatingTransitions;

- (void)startAnimating
{
	if (self.animationImages.count > 0 && ! _isAnimatingTransitions)
	{
		NSTimer *transitionTimer = [NSTimer timerWithTimeInterval:self.animationDuration / self.animationImages.count target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
		[NSRunLoop.mainRunLoop addTimer:transitionTimer forMode:NSDefaultRunLoopMode];
		_transitionTimer = transitionTimer;
		
		__weak typeof(self) nonretainedSelf = self;
		[UIView transitionWithView:self duration:self.animatedTransitionDuration options:self.animatedTransitionOptions animations:^
		{
			__strong typeof(nonretainedSelf) retainedSelf = nonretainedSelf;
            if (! retainedSelf)
                return;
			[super setImage:retainedSelf.animationImages[retainedSelf->_currentImageIndex = 0]];
		} completion:nil];
		
		_isAnimatingTransitions = YES;
	}
}

- (void)stopAnimating
{
	[_transitionTimer invalidate];
	_isAnimatingTransitions = NO;
}

- (void)setImage:(UIImage *)image
{
	[self stopAnimating];
	[super setImage:image];
}

- (void)timerFired:(NSTimer *)timer
{
	if (! self.superview)
	{
		[timer invalidate];
		return;
	}
	__weak typeof(self) nonretainedSelf = self;
	[UIView transitionWithView:self duration:self.animatedTransitionDuration options:self.animatedTransitionOptions animations:^
	{
		__strong typeof(nonretainedSelf) retainedSelf = nonretainedSelf;
        if (! retainedSelf)
            return;
		retainedSelf->_currentImageIndex = (retainedSelf->_currentImageIndex+1) % retainedSelf.animationImages.count;
		[super setImage:retainedSelf.animationImages[retainedSelf->_currentImageIndex]];
	} completion:nil];
}

@end
