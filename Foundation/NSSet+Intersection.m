//
//  2014 Magna cum laude. PD
//

#import "NSSet+Intersection.h"

@implementation NSSet (Intersection)

- (NSSet *)intersectionWithSet:(NSSet *)set
{
    return [self objectsPassingTest:^ BOOL(id obj, BOOL *stop) { return [set containsObject:obj]; }];
}

@end
