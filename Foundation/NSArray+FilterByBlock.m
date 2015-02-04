//
//  2014 Magna cum laude. PD
//

#import "NSArray+FilterByBlock.h"

@implementation NSArray (FilterByBlock)

- (NSArray *)objectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
	return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:test]];
}

@end
