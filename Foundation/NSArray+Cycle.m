//
//  2014 Magna cum laude. PD
//

#import "NSArray+Cycle.h"

@implementation NSArray (Cycle)

- (NSArray *)arrayByCyclingFromIndex:(NSUInteger)index
{
    return [[self subarrayWithRange:NSMakeRange(index, self.count-index)] arrayByAddingObjectsFromArray:[self subarrayWithRange:NSMakeRange(0, index)]];
}

@end
