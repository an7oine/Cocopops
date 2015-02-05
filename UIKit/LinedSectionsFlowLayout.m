//
//  2014 Magna cum laude. PD
//

#import "LinedSectionsFlowLayout.h"

#import "NSArray+FilterByBlock.h" // available in ../Foundation


NSString *const UICollectionElementKindSectionLining = @"UICollectionElementKindSectionLining";

@implementation LinedSectionsFlowLayout
{
	NSArray *_sectionLiningAttributes;
}

// prepare all sections' lining attributes beforehand
- (void)prepareLayout
{
	[super prepareLayout];

	NSMutableArray *sectionLiningAttributes = [NSMutableArray new];
	for (int i=0; i < self.collectionView.numberOfSections; i++)
	{
		UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionLining withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];

		// if there is at least one item, make a union rectangle of first and last item's layout rectangles
		// then extend it maximally along the non-scrolling axis, and add sectionInsets along the scrolling axis
		NSInteger lastRow = [self.collectionView numberOfItemsInSection:i] - 1;
		if (lastRow >= 0)
		{
			UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
			UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:i]];
			CGRect frame = CGRectUnion(firstItem.frame, lastItem.frame);
			frame.origin.x -= self.sectionInset.left;
			frame.origin.y -= self.sectionInset.top;
			if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
			{
				frame.size.width += self.sectionInset.left + self.sectionInset.right;
				frame.size.height = self.collectionView.frame.size.height;
			}
			else //(self.scrollDirection == UICollectionViewScrollDirectionVertical)
			{
				frame.size.width = self.collectionView.frame.size.width;
				frame.size.height += self.sectionInset.top + self.sectionInset.bottom;
			}

			// expand to the smallest covering area of whole pixels
			attributes.frame = CGRectIntegral(frame);
		}

		[sectionLiningAttributes addObject:attributes];
	}
	_sectionLiningAttributes = sectionLiningAttributes;
}

// return lining attributes or refer to super
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if (kind == UICollectionElementKindSectionLining)
		return _sectionLiningAttributes[indexPath.section];
	else
		return [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
}

// add lining attributes to super's implementation
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray *liningAttributes = [_sectionLiningAttributes objectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *obj, NSUInteger idx, BOOL *stop) {
		return CGRectIntersectsRect(rect, obj.frame);
	}];
	return [[super layoutAttributesForElementsInRect:rect] arrayByAddingObjectsFromArray:liningAttributes];
}

@end
