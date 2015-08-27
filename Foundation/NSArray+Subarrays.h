//
//  2015 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (Subarrays)

- (void)enumerateSubarraysWithCount:(NSInteger)count usingBlock:(void (^)(NSArray *items))block;

@end
