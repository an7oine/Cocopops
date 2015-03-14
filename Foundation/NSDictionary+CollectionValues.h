//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CollectionValues)

// return any key for which the value satisfies [value containsObject:object]
- (NSSet *)keysForCollectionsContainingObject:(id)object;
- (id)keyForCollectionContainingObject:(id)object;

@end
