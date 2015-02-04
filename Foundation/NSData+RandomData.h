//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSData (RandomData)

// create a new NSData instance with given size, randomized content
+ (instancetype)randomDataWithSize:(size_t)size;

@end
