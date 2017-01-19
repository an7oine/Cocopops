//
//  2016 Magna cum laude. PD
//

#import "NSDictionary+IgnoreNil.h"
#import "NSObject+SwizzleMethods.h"

@implementation NSDictionary (IgnoreNil)

+ (instancetype)dictionaryWithObjectsIgnoringNil:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)count
{
	id _Nonnull __unsafe_unretained *nonnilObjects = (id _Nonnull __unsafe_unretained *)malloc(((size_t)count) * sizeof(id));
	id<NSCopying> _Nonnull __unsafe_unretained *nonnilKeys = (id<NSCopying> _Nonnull __unsafe_unretained *)malloc(((size_t)count) * sizeof(id<NSCopying>));
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
		[self exchangeClassImplementationsWithSelector:@selector(dictionaryWithObjects:forKeys:count:) andSelector:@selector(dictionaryWithObjectsIgnoringNil:forKeys:count:)];
	});
}

@end
