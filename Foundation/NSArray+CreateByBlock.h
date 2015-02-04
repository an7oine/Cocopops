//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (CreateByBlock)

+ (instancetype)arrayWithSize:(NSUInteger)size byBlock:(id (^)(NSArray *priorObjects, NSUInteger idx))block; // creates an array inductively 

@end
