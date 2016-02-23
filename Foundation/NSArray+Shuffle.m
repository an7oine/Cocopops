//
//  2015 Magna cum laude. PD
//

#import "NSArray+Shuffle.h"

@implementation NSArray (Shuffle)

- (NSArray *)shuffledArray
{
	NSMutableArray *result = self.mutableCopy;
	for (NSInteger i = self.count-1; i >= 1; i--)
		[result exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform(i+1)];
	return result;
}

@end
