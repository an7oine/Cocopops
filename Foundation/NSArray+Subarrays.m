//
//  2015 Magna cum laude. PD
//

#import "NSArray+Subarrays.h"

@implementation NSArray (Subarrays)

- (void)enumerateSubarraysWithCount:(NSInteger)count usingBlock:(void (^)(NSArray *items))block
{
    if (count >= self.count)
        block(self);
    else if (count <= 0)
        block(@[]);
    else
    {
        [[self subarrayWithRange:NSMakeRange(1, self.count-1)] enumerateSubarraysWithCount:count-1 usingBlock:^void(NSArray *items)
        {
            block([@[ self.firstObject ] arrayByAddingObjectsFromArray:items]);
        }];
        [[self subarrayWithRange:NSMakeRange(1, self.count-1)] enumerateSubarraysWithCount:count usingBlock:block];
    }
}

@end
