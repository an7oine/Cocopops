//
//  2017 Magna cum laude. PD
//

#import "NSObject+SwizzleMethods.h"

#import <objc/runtime.h>

@implementation NSObject (SwizzleMethods)

+ (void)exchangeClassImplementationsWithSelector:(SEL)selectorA andSelector:(SEL)selectorB
{
	Method methodA = class_getClassMethod(self, selectorA);
	Method methodB = class_getClassMethod(self, selectorB);

	if (class_addMethod(object_getClass(self), selectorA, method_getImplementation(methodB), method_getTypeEncoding(methodB)))
		class_replaceMethod(object_getClass(self), selectorB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
	else
		method_exchangeImplementations(methodA, methodB);
}

+ (void)exchangeInstanceImplementationsWithSelector:(SEL)selectorA andSelector:(SEL)selectorB
{
	Method methodA = class_getInstanceMethod(self, selectorA);
	Method methodB = class_getInstanceMethod(self, selectorB);

	if (class_addMethod(self.class, selectorA, method_getImplementation(methodB), method_getTypeEncoding(methodB)))
		class_replaceMethod(self.class, selectorB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
	else
		method_exchangeImplementations(methodA, methodB);
}

@end
