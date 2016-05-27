//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (DeriveArray)

// derive a new array by invoking the block with each original element
- (NSArray *)deriveArrayUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
