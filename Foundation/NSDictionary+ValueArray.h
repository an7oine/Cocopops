//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ValueArray)

// derive a new array containing values for the given keys
- (NSArray *)valuesWithKeys:(NSArray *)keys;

@end
