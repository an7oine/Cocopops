//
//  2015 Magna cum laude. PD
//

#import "NSSet+RemoveObject.h"

@implementation NSSet (RemoveObject)

- (NSSet *)setByRemovingObject:(id)object
{
    NSMutableSet *result = self.mutableCopy;
    [result removeObject:object];
    return result;
}

- (NSSet *)setByRemovingObjectsInSet:(NSSet *)set
{
    NSMutableSet *result = self.mutableCopy;
    [result minusSet:set];
    return result;
}

@end
