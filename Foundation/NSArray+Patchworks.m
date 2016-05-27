//
//  2016 Magna cum laude. PD
//

#import "NSArray+Patchworks.h"
#import "NSArray+RemoveObject.h"

@implementation NSArray (Patchworks)

// a private recursion cluster
- (void)enumeratePatchworksFromNode:(id)node usingBlock:(BOOL (^)(NSArray *patchwork))block
{
	for (NSArray *initialArray in self)
	{
		NSArray<NSArray *> *restOfSelf = [self arrayByRemovingObject:initialArray];

		// search for the junction node in this array
		NSIndexSet *initialIndexSet = [initialArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
		{
			return [obj isEqual:node];
		}];
		
		// then process each junction point found
		[initialIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop)
		{
			// enumerate 'initialArray' forward beginning at 'idx'+1
			if (idx < initialArray.count-1)
			{
				NSMutableArray *forwardSubarray = [NSMutableArray new];
				for (id node in [initialArray subarrayWithRange:NSMakeRange(idx+1, initialArray.count-idx-1)])
				{
					// report this result
					[forwardSubarray addObject:node];
					if (! block(forwardSubarray))
						return;
					
					// proceed to search for further joints, in rest of the arrays, at each step
					[restOfSelf enumeratePatchworksFromNode:node usingBlock:^BOOL(NSArray *patchwork)
					{
						if (! block([forwardSubarray arrayByAddingObjectsFromArray:patchwork]))
							return NO;
						else
							return YES;
					}];
				}
			}
			
			// enumerate 'initialArray' backward beginning at 'idx'-1
			if (idx > 0)
			{
				NSMutableArray *backwardSubarray = [NSMutableArray new];
				for (id node in [initialArray subarrayWithRange:NSMakeRange(0, idx)].reverseObjectEnumerator)
				{
					// report this result
					[backwardSubarray addObject:node];
					if (! block(backwardSubarray))
						return;

					// proceed to search for further joints, in rest of the arrays, at each step
					[restOfSelf enumeratePatchworksFromNode:node usingBlock:^BOOL(NSArray *patchwork)
					{
						if (! block([backwardSubarray arrayByAddingObjectsFromArray:patchwork]))
							return NO;
						else
							return YES;
					}];
				}
			}
		}];
	}
}

- (void)enumeratePatchworksUsingBlock:(BOOL (^)(NSArray *patchwork))block
{
	__block BOOL keepGoing = YES;

	for (NSArray *initialArray in self)
	{
		// test for abortion at each iteration
		if (! keepGoing)
			return;

		NSArray<NSArray *> *restOfSelf = [self arrayByRemovingObject:initialArray];

		// enumerate all subarrays beginning at initialArray's head
		NSMutableArray *forwardSubarray = [NSMutableArray new];
		for (id node in initialArray)
		{
			// report the result as-is
			[forwardSubarray addObject:node];
			if (! block(forwardSubarray))
				return;
			
			// then proceed to find junctions within the other arrays
			[restOfSelf enumeratePatchworksFromNode:node usingBlock:^BOOL(NSArray *patchwork)
			{
				// give the client a chance to abort at each iteration, and stop asking when aborted
				if (! keepGoing)
					return NO;
				else if (! block([forwardSubarray arrayByAddingObjectsFromArray:patchwork]))
					return (keepGoing = NO);
				else
					return YES;
			}];
		}
		
		// enumerate all reverse subarrays beginning at initialArray's tail
		NSMutableArray *backwardSubarray = [NSMutableArray new];
		for (id node in initialArray.reverseObjectEnumerator)
		{
			// report the result as-is
			[backwardSubarray addObject:node];
			if (! block(backwardSubarray))
				return;

			// then proceed to find junctions within the other arrays
			[restOfSelf enumeratePatchworksFromNode:node usingBlock:^BOOL(NSArray *patchwork)
			{
				// give the client a chance to abort at each iteration, and stop asking when aborted
				if (! keepGoing)
					return NO;
				else if (! block([backwardSubarray arrayByAddingObjectsFromArray:patchwork]))
					return (keepGoing = NO);
				else
					return YES;
			}];
		}
	}
}

@end
