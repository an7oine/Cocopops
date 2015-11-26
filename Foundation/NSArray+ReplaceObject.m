//
//  2015 Magna cum laude. PD
//

#import "NSArray+ReplaceObject.h"

@implementation NSArray (ReplaceObject)

- (NSArray *)arrayByReplacingObject:(id)object withObject:(id)newObject
{
	NSUInteger index = [self indexOfObject:object];
	return index != NSNotFound? [[[self subarrayWithRange:NSMakeRange(0, index)] arrayByAddingObject:newObject] arrayByAddingObjectsFromArray:[self subarrayWithRange:NSMakeRange(index+1, self.count-index-1)]] : self;
}

@end
