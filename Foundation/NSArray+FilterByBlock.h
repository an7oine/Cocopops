//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (FilterByBlock)

/**
 Return objects qualified by given block
 */
- (NSArray *)objectsPassing:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test;

/**
 Return the first object qualified by given block
 */
- (id)firstObjectPassing:(BOOL (^)(id obj, NSUInteger idx))test;

@end
