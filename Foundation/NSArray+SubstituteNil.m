//
//  2016 Magna cum laude. PD
//

#import "NSArray+SubstituteNil.h"
#import "NSObject+SwizzleMethods.h"

@implementation NSArray (SubstituteNil)

+ (instancetype)arrayWithObjectsSubstitutingNil:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)count
{
	id _Nonnull __unsafe_unretained *nonnilObjects = (id _Nonnull __unsafe_unretained *)malloc(((size_t)count) * sizeof(id));

	for (NSUInteger i=0; i < count; i++)
	{
		id object = objects[i];
		if (object)
			nonnilObjects[i] = object;
		else
			nonnilObjects[i] = NSNull.null;
	}

	// invoke the original @[ ] interpreter
	NSArray *array = [self arrayWithObjectsSubstitutingNil:nonnilObjects count:count];

	free(nonnilObjects);

	return array;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		[self exchangeClassImplementationsWithSelector:@selector(arrayWithObjects:count:) andSelector:@selector(arrayWithObjectsSubstitutingNil:count:)];
	});
}

@end
