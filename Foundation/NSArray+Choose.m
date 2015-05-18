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
	NSArray *restOfSelf = [self subarrayWithRange:NSMakeRange(1, self.count-1)];

	if ([self.firstObject count] == 0)
	{
		prependedItems[0] = NSNull.null;
		return [restOfSelf chooseWithBlock:^BOOL(NSArray *items)
	    {
			[prependedItems replaceObjectsInRange:NSMakeRange(1, self.count-1) withObjectsFromArray:items];
			return block(prependedItems);
		}];
	}

	BOOL result = YES;
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
