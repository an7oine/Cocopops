//
//  2017 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ProxyDictionary)

/**
Create and return a dictionary proxy, mapping key-value retrieval and assignment into method calls.
@param target the receiver's target, against which the assigned selectors are performed
@param getter a (read-only) selector with signature @c -[valueForKey:]
@param setter a (write-only) selector with signature @c -[setValue:forKey:]
 */
+ (instancetype)dictionaryForTarget:(id)target getter:(SEL)getter setter:(SEL)setter;

@end
