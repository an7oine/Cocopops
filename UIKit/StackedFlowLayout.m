//
//  2014 Magna cum laude. PD
//

#import "StackedFlowLayout.h"

#import "NSArray+DeepCopy.h"

@implementation StackedFlowLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
	attributes.zIndex = self.collectionViewContentSize.width - attributes.center.x + attributes.center.y;
	attributes.transform3D = CATransform3DMakeTranslation(0.0f, 0.0f, attributes.zIndex);
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *allAttributes = [[super layoutAttributesForElementsInRect:rect] deepCopy];
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
