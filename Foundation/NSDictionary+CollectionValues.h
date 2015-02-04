//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CollectionValues)

- (id)keyForCollectionContainingObject:(id)object; // return any key for which the value satisfies [value containsObject:object]

@end
