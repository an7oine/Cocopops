//
//  2014 Magna cum laude. PD
//

#import "NSDictionary+ValueArray.h"

@implementation NSDictionary (ValueArray)

- (NSArray *)valuesForKeys:(NSArray *)keys
{
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:keys.count];
	for (id key in keys)
		if ([self.allKeys containsObject:key])
			[result addObject:self[key]];
	return result;
}

@end
