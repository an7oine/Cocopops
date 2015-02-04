//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (CreateByBlock)

// create an array inductively
+ (instancetype)arrayWithSize:(NSUInteger)size byBlock:(id (^)(NSArray *priorObjects, NSUInteger idx))block;

@end
