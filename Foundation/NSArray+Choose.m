//
//  2015 Magna cum laude. PD
//

#import "NSArray+Choose.h"
#import "choose.h"

@implementation NSArray (Choose)

- (BOOL)chooseWithBlock:(BOOL (^)(NSArray *items))block
{
	if (self.count == 0)
		return block(@[]);
	NSMutableArray *prependedItems = [NSMutableArray arrayWithArray:self];
	BOOL result = YES;
	NSArray *restOfSelf = [self subarrayWithRange:NSMakeRange(1, self.count-1)];
	for (id obj in self.firstObject)
	{
		prependedItems[0] = obj;
		if (! [restOfSelf chooseWithBlock:^BOOL(NSArray *items)
		{
			[prependedItems replaceObjectsInRange:NSMakeRange(1, self.count-1) withObjectsFromArray:items];
			return block(prependedItems);
		}])
		{
			result = NO;
			break;
		}
	}
	return result;
}

@end
