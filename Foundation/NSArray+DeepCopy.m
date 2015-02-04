//
//  2014 Magna cum laude. PD
//

#import "NSArray+DeepCopy.h"

@implementation NSArray (DeepCopy)

- (NSArray *)deepCopy
{
	NSMutableArray *array = [NSMutableArray new];
	for (id item in self)
		[array addObject:[item copy]];
	return array;
}

@end
