//
//  2014 Magna cum laude. PD
//

#import "NSArray+FilterByBlock.h"

@implementation NSArray (FilterByBlock)

- (NSArray *)objectsPassing:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
	return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:test]];
}

- (id)firstObjectPassing:(BOOL (^)(id obj, NSUInteger idx))test
{
	NSInteger index = [self indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
	{
		return test(obj, idx) && (*stop = YES);
	}];
	return index == NSNotFound? nil : [self objectAtIndex:index];
}

@end
