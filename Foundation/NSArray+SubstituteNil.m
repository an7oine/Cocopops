//
//  2016 Magna cum laude. PD
//

#import "NSArray+SubstituteNil.h"

@import ObjectiveC.runtime;

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
		SEL selectorA = @selector(arrayWithObjects:count:);
		SEL selectorB =  @selector(arrayWithObjectsSubstitutingNil:count:);
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
