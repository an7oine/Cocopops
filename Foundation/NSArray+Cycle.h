//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (Cycle)

- (NSArray *)arrayByCyclingFromIndex:(NSUInteger)index; // creates a new array where self[index] is firstObject, self[index-1] is lastObject

@end
