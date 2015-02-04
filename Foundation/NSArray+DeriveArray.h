//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (DeriveArray)

- (NSArray *)deriveArrayUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block; // derives a new array by invoking the block with each original element

@end
