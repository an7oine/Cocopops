//
//  2017 Magna cum laude. PD
//

#import "NSDictionary+ProxyDictionary.h"

@interface ProxyDictionary : NSMutableDictionary

@property (nonatomic, weak) id target;
@property (nonatomic) SEL getter, setter;
@end

@implementation ProxyDictionary

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)objectForKey:(NSString *)key
{
	NSAssert(self.getter, @"%@: no getter selector!", NSStringFromClass(self.class));
	return [self.target performSelector:self.getter withObject:key];
}
- (void)setObject:(id)value forKey:(NSString *)key
{
	NSAssert(self.setter, @"%@: no setter selector!", NSStringFromClass(self.class));
	[self.target performSelector:self.setter withObject:value withObject:key];
}
#pragma clang diagnostic pop

- (void)removeObjectForKey:(id)aKey
{
	[self setValue:nil forKey:aKey];
}
- (instancetype)initWithObjectsAndKeys:(id)firstObject, ...
{
	return nil;
}
- (NSUInteger)count
{
	return 0;
}
- (NSEnumerator *)keyEnumerator
{
	return [NSEnumerator new];
}

+ (instancetype)proxyDictionaryWithTarget:(id)target getter:(SEL)getter setter:(SEL)setter
{
	ProxyDictionary *dictionary = [self new];
	dictionary.target = target;
	dictionary.getter = getter;
	dictionary.setter = setter;
	return dictionary;
}

@end

@implementation NSDictionary (ProxyDictionary)

+ (instancetype)dictionaryForTarget:(id)target getter:(SEL)getter setter:(SEL)setter
{
	return [ProxyDictionary proxyDictionaryWithTarget:target getter:getter setter:setter];
}

@end
