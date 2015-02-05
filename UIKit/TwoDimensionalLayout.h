//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

// Two-Dimensional Collection View Layout, where:
// sections amount to rows from North to South
// items amount to consecutive cells on one row from West to East

@interface TwoDimensionalLayout : UICollectionViewLayout

// extremes of the grid in use
@property (nonatomic) NSInteger west, east;
@property (nonatomic) NSInteger north, south;

// set horizontally adjacent items logically apart by this factor (defaults to 1, 2 is hexagonal)
// note that cells are always enumerated from 0 to however many cells fit on each row
// example: hexagonal grid with north=0, south=2, west=0, east=2,
// so that logical item coordinates and their corresponding (section,item) pairs are:
// 0-0,0-2,0-4, 1-1,1-3, 2-0,2-2,2-4 / (0,0),(0,1),(0,2), (1,0),(1,1), (2,0),(2,1),(2,2)
@property (nonatomic) NSInteger adjacentItemsSeparation;

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

// override in subclass, if needed
- (UICollectionViewLayoutAttributes *)createLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
