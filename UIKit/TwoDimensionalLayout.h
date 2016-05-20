//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@protocol TwoDLayoutDelegate;

// Two-Dimensional Collection View Layout, where:
// sections amount to rows from North to South
// items amount to consecutive cells on one row from West to East

@interface TwoDimensionalLayout : UICollectionViewLayout <NSCopying>

// extremes of the grid in use
@property (nonatomic) NSInteger west, east;
@property (nonatomic) NSInteger north, south;

// set horizontally adjacent items logically apart by this factor (defaults to 1, 2 is hexagonal)
// note that cells are always enumerated from 0 to however many cells fit on each row
// example: hexagonal grid with north=0, south=2, west=0, east=2,
// so that logical item coordinates and their corresponding (section,item) pairs are:
// 0-0,0-2,0-4, 1-1,1-3, 2-0,2-2,2-4 / (0,0),(0,1),(0,2), (1,0),(1,1), (2,0),(2,1),(2,2)
@property (nonatomic) NSInteger adjacentItemsSeparation;

// wrap content at viewport width and separate by this height
@property (nonatomic) BOOL wrapHorizontally;
@property (nonatomic) CGFloat wraparoundSpacing; // extra (proportional) vertical space between rows of wrapped content
- (CGFloat)horizontalWrappingWidth; // width beyond which content is clipped and wrapped around

// methods to request information about the layout
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSInteger)rowOfCellWithIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)columnOfCellWithIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfCellInRow:(NSInteger)row column:(NSInteger)column;

- (NSInteger)westernBoundInSection:(NSInteger)section;
- (NSInteger)easternBoundInSection:(NSInteger)section;

// graphic properties of items on the grid
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize itemSpacing;
@property (nonatomic) CGFloat zoomFactor;

// margins around the content
@property (nonatomic) CGFloat marginPerItem;
@property (nonatomic, readonly) CGFloat margin;

// delegate
@property (nonatomic, weak) id <TwoDLayoutDelegate> delegate;

@property (nonatomic, readonly) CGPoint contentOrigin;
- (CGRect)frameForRow:(NSInteger)row column:(NSInteger)column;

// override in subclass, if needed
- (CGAffineTransform)transform;
- (CGRect)cellFrameWithFrame:(CGRect)frame;
- (UICollectionViewLayoutAttributes *)createLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TwoDLayoutDelegate <NSObject>
@optional
- (BOOL)layout:(TwoDimensionalLayout *)layout shouldIncludeActiveCellInRow:(NSInteger)row column:(NSInteger)column;
@end
