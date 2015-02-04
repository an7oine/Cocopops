//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (Cycle)

// create a new array where self[index] is firstObject, self[index-1] is lastObject
- (NSArray *)arrayByCyclingFromIndex:(NSUInteger)index;

@end
