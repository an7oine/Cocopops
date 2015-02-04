//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (FilterByBlock)

- (NSArray *)objectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test; // returns objects qualified by the test block

@end
