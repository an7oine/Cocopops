//
//  2014 Magna cum laude. PD
//

#import "NSArray+CreateByBlock.h"

@implementation NSArray (CreateByBlock)

+ (instancetype)arrayWithSize:(NSUInteger)size byBlock:(id (^)(NSArray *priorObjects, NSUInteger idx))block
{
	NSMutableArray *result = [NSMutableArray new];
	for (NSUInteger i=0; i < size; i++)
		[result addObject:block(result.copy, i)];
	return result;
}

@end
