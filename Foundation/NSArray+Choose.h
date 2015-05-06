//
//  2015 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (Choose)

// choose one object from each sub-NSArray contained in 'self' and pass all such combinations of choices to 'block';
// cancel operation and return 'NO' if some invocation of 'block' returns 'NO'; finish and return 'YES' otherwise
- (BOOL)chooseWithBlock:(BOOL (^)(NSArray *items))block;

@end
