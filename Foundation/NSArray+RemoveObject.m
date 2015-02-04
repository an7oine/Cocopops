//
//  2014 Magna cum laude. PD
//

#import "NSArray+RemoveObject.h"

@implementation NSArray (RemoveObject)

- (NSArray *)arrayByRemovingFirstObject
{
    return [self subarrayWithRange:NSMakeRange(1, self.count-1)];
}

- (NSArray *)arrayByRemovingLastObject
{
    return [self subarrayWithRange:NSMakeRange(0, self.count-1)];
}

- (NSArray *)arrayByRemovingObject:(id)object
{
    NSUInteger index = [self indexOfObject:object];
    return index != NSNotFound? [[self subarrayWithRange:NSMakeRange(0, index)] arrayByAddingObjectsFromArray:[self subarrayWithRange:NSMakeRange(index+1, self.count-index-1)]] : self;
}

@end
