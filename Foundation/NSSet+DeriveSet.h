//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSSet (DeriveSet)

- (NSSet *)deriveSetUsingBlock:(id (^)(id obj, BOOL *stop))block; // derives a new set by invoking the block with each original element

@end
