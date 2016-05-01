//
//  2016 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

/**
Empty category that overrides the interpreter for literal @{ } syntax
so that nil keys/values are silently ignored instead of raising an exception
 */
@interface NSDictionary (IgnoreNil)

@end
