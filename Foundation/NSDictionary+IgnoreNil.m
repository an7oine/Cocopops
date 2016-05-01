//
//  2016 Magna cum laude. PD
//

#import "NSDictionary+IgnoreNil.h"

@import ObjectiveC.runtime;

@implementation NSDictionary (IgnoreNil)

+ (instancetype)dictionaryWithObjectsIgnoringNil:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)count
{
	id _Nonnull __unsafe_unretained *nonnilObjects = (id _Nonnull __unsafe_unretained *)malloc(((size_t)count) * sizeof(id));
	id<NSCopying> _Nonnull __unsafe_unretained *nonnilKeys = (id<NSCopying> _Nonnull __unsafe_unretained *)malloc(((size_t)count) * sizeof(id));
	NSUInteger nonnilCount = 0;

	for (NSUInteger i=0; i < count; i++)
	{
		id object = objects[i], key = keys[i];
		if (object && key)
			nonnilObjects[nonnilCount] = object, nonnilKeys[nonnilCount] = key, nonnilCount++;
	}

	// invoke the original @{ } interpreter
	NSDictionary *dictionary = [self dictionaryWithObjectsIgnoringNil:nonnilObjects forKeys:nonnilKeys count:nonnilCount];

	free(nonnilObjects);
	free(nonnilKeys);

	return dictionary;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		SEL selectorA = @selector(dictionaryWithObjects:forKeys:count:);
		SEL selectorB =  @selector(dictionaryWithObjectsIgnoringNil:forKeys:count:);
		Method methodA = class_getClassMethod(self, selectorA);
		Method methodB = class_getClassMethod(self, selectorB);

		Class meta = object_getClass(self);

		if (class_addMethod(meta, selectorA, method_getImplementation(methodB), method_getTypeEncoding(methodB)))
			class_replaceMethod(meta, selectorB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
		else
			method_exchangeImplementations(methodA, methodB);
	});
}

@end
