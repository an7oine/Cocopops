//
//  2017 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSObject (SwizzleMethods)

+ (void)exchangeClassImplementationsWithSelector:(SEL)selectorA andSelector:(SEL)selectorB;
+ (void)exchangeInstanceImplementationsWithSelector:(SEL)selectorA andSelector:(SEL)selectorB;

@end
