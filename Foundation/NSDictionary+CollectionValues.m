//
//  2014 Magna cum laude. PD
//

#import "NSDictionary+CollectionValues.h"

@implementation NSDictionary (CollectionValues)

- (id)keyForCollectionContainingObject:(id)object
{
    for (id key in self.allKeys)
        if ([self[key] containsObject:object])
            return key;
    return nil;
}

@end
