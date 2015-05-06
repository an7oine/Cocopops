//
//  2015 Magna cum laude. PD
//

#import "NSIndexSet+Arrays.h"

@implementation NSIndexSet (Arrays)

- (instancetype)initWithArray:(NSArray *)array
{
	NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
	for (id index in array)
		[indexSet addIndex:[index integerValue]];
	return [self initWithIndexSet:indexSet];
}

- (NSArray *)array
{
	NSMutableArray *array = [NSMutableArray new];
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[array addObject:@( idx )];
	}];
	return array;
}

@end
