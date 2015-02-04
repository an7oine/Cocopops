//
//  2014 Magna cum laude. PD
//

#import "NSArray+DeriveArray.h"

@implementation NSArray (DeriveArray)

- (NSArray *)deriveArrayUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in self)
    {
        BOOL stop = NO;
        id resultObj = block(obj, [self indexOfObject:obj], &stop);
        if (resultObj)
            [result addObject:resultObj];
        else if (!stop)
            [result addObject:NSNull.null];
        if (stop)
            break;
    }
    return result;
}

@end
