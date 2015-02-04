//
//  2014 Magna cum laude. PD
//

#import "NSSet+DeriveSet.h"

@implementation NSSet (DeriveSet)

- (NSSet *)deriveSetUsingBlock:(id (^)(id obj, BOOL *stop))block
{
    NSMutableSet *result = [NSMutableSet new];
    for (id obj in self)
    {
        BOOL stop = NO;
        id resultObj = block(obj, &stop);
        if (resultObj)
            [result addObject:resultObj];
        if (stop)
            break;
    }
    return result;
}

@end
