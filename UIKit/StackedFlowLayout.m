//
//  2014 Magna cum laude. PD
//

#import "StackedFlowLayout.h"

@implementation StackedFlowLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
	attributes.zIndex = self.collectionViewContentSize.width - attributes.center.x + attributes.center.y;
	attributes.transform3D = CATransform3DMakeTranslation(0.0f, 0.0f, attributes.zIndex);
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *allAttributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in allAttributes)
	{
		if (attributes.representedElementCategory == UICollectionElementCategoryCell)
		{
			attributes.zIndex = self.collectionViewContentSize.width - attributes.center.x + attributes.center.y;
			attributes.transform3D = CATransform3DMakeTranslation(0.0f, 0.0f, attributes.zIndex);
		}
	}
    return allAttributes;
}

@end
