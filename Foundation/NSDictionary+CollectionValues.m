//
//  2014 Magna cum laude. PD
//

#import "NSDictionary+CollectionValues.h"

@implementation NSDictionary (CollectionValues)

- (NSSet *)keysForCollectionsContainingObject:(id)object
{
	return [[NSSet setWithArray:self.allKeys] objectsPassingTest:^BOOL(id obj, BOOL *stop)
	{
		return [self[obj] containsObject:object];
	}];
}

- (id)keyForCollectionContainingObject:(id)object
{
    for (id key in self.allKeys)
        if ([self[key] containsObject:object])
            return key;
    return nil;
}

@end
