//
//  2014 Magna cum laude. PD
//

#import "TwoDimensionalLayout.h"

#import "NSArray+FilterByBlock.h"

@implementation TwoDimensionalLayout
{
    NSMutableDictionary *_layoutAttributes;
}

- (void)setDefaultValues
{
    // establish some sane values
    self.itemSize = CGSizeMake(50.0f, 50.0f);
    self.itemSpacing = CGSizeMake(self.itemSize.width*11.0f/10.0f, self.itemSize.height*11.0f/10.0f);
    self.zoomFactor = 1.0f;
    self.adjacentItemsSeparation = 1;
}

- (id)init
{
    if (! (self = [super init]))
        return nil;
    [self setDefaultValues];
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (! (self = [super initWithCoder:aDecoder]))
        return nil;
    [self setDefaultValues];
    return self;
}


#pragma mark - Dimensions & zooming

@synthesize itemSize=_itemSize, itemSpacing=_itemSpacing, zoomFactor=_zoomFactor;
- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize; [self invalidateLayout];
}
- (void)setItemSpacing:(CGSize)itemSpacing
{
    _itemSpacing = itemSpacing; [self invalidateLayout];
}
- (void)setZoomFactor:(CGFloat)zoomFactor
{
    _zoomFactor = zoomFactor; [self invalidateLayout];
}
- (void)applyZoomFactor:(CGFloat)zoomFactor
{
    self.zoomFactor *= zoomFactor;
}


#pragma mark - Helpers

- (NSInteger)numberOfSections { return self.south - self.north + 1; }
- (NSInteger)phaseOf:(NSInteger)index
{
	NSInteger phase = index;
	while (phase < 0)
		phase += self.adjacentItemsSeparation;
	return phase % self.adjacentItemsSeparation;
}
- (NSInteger)westernBoundInSection:(NSInteger)section
{
	NSInteger rowPhase = [self phaseOf:self.north+section], westPhase = [self phaseOf:self.west];
    NSInteger phaseDiff = rowPhase<westPhase? westPhase-rowPhase : rowPhase-westPhase;
    return self.west + phaseDiff;
}
- (NSInteger)easternBoundInSection:(NSInteger)section
{
	NSInteger rowPhase = [self phaseOf:self.north+section], eastPhase = [self phaseOf:self.east];
	NSInteger phaseDiff = rowPhase<eastPhase? eastPhase-rowPhase : rowPhase-eastPhase;
    return self.east - phaseDiff;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
	if ([self easternBoundInSection:section] < [self westernBoundInSection:section])
		return 0;
	else
		return ([self easternBoundInSection:section] - [self westernBoundInSection:section]) / self.adjacentItemsSeparation + 1;
}

- (NSInteger)rowOfCellWithIndexPath:(NSIndexPath *)indexPath
{
	return self.north + indexPath.section;
}

- (NSInteger)columnOfCellWithIndexPath:(NSIndexPath *)indexPath
{
	return [self westernBoundInSection:indexPath.section] + indexPath.item * self.adjacentItemsSeparation;
}

- (NSIndexPath *)indexPathOfCellInRow:(NSInteger)row column:(NSInteger)column
{
	NSInteger section = row - self.north;
	NSInteger item = (column - [self westernBoundInSection:section]) / self.adjacentItemsSeparation;
	return [NSIndexPath indexPathForItem:item inSection:section];
}

- (CGRect)frameForRow:(NSInteger)row column:(NSInteger)column
{
	CGFloat width = self.itemSize.width * self.zoomFactor;
	CGFloat height = self.itemSize.height * self.zoomFactor;
	CGRect frame = CGRectMake(
                      (column - self.west) * self.itemSpacing.width * self.zoomFactor,
                      (row - self.north) * self.itemSpacing.height * self.zoomFactor,
                      width,
					  height
                      );
	if ([self respondsToSelector:@selector(cellTransform)])
	{
		CGRect transformedFrame = CGRectApplyAffineTransform(frame, self.cellTransform);
		CGPoint centre = CGPointMake(CGRectGetMidX(transformedFrame), CGRectGetMidY(transformedFrame));
		return [self cellFrameWithFrame:CGRectMake(centre.x-0.5f*width, centre.y-0.5f*height, width, height)];
	}
	else
		return frame;
}

- (UICollectionViewLayoutAttributes *)createLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [self.class.layoutAttributesClass layoutAttributesForCellWithIndexPath:indexPath];

    NSInteger row = [self rowOfCellWithIndexPath:indexPath];
    NSInteger column = [self columnOfCellWithIndexPath:indexPath];

    attributes.frame = [self frameForRow:row column:column];
    attributes.zIndex = -column;

    return attributes;
}


#pragma mark - UICollectionViewLayout methods

- (void)prepareLayout
{
    NSMutableDictionary *layoutAttributes = [NSMutableDictionary new];

    for (NSInteger section=0, row = self.north; row <= self.south; section++, row++)
        for (NSInteger item=0, column = [self westernBoundInSection:section]; column <= [self easternBoundInSection:section]; item++, column+=self.adjacentItemsSeparation)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            layoutAttributes[indexPath] = [self createLayoutAttributesForItemAtIndexPath:indexPath];
        }

    _layoutAttributes = layoutAttributes;
}

- (CGSize)collectionViewContentSize
{
	CGRect frame = [self frameForRow:self.north column:self.west];
	frame = CGRectUnion(frame, [self frameForRow:self.north column:self.east]);
	frame = CGRectUnion(frame, [self frameForRow:self.south column:self.west]);
	frame = CGRectUnion(frame, [self frameForRow:self.south column:self.east]);
	return CGRectIntegral(frame).size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [_layoutAttributes.allValues objectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *obj, NSUInteger idx, BOOL *stop) {
        return CGRectIntersectsRect(rect, obj.frame);
    }];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _layoutAttributes[indexPath];
}

@end
