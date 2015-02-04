//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSSet (DeriveSet)

// derive a new set by invoking block with each original element
- (NSSet *)deriveSetUsingBlock:(id (^)(id obj, BOOL *stop))block;

@end
