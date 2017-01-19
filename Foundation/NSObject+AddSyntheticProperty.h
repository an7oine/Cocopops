//
//  2016 Magna cum laude. PD
//

#import <objc/runtime.h>

#define ADD_SYNTHETIC_PROPERTY_TO_CLASS(c, t, g, s, r) @interface c (g) \
@property (nonatomic, getter=g, setter=s:) t g; \
@end \
@implementation c (g) \
- (t)g { return objc_getAssociatedObject(self, @selector(g)); } \
- (void)s:(t)g { objc_setAssociatedObject(self, @selector(g), g, OBJC_ASSOCIATION_ ## r); } \
@end

#define PACKED_ARG(...) __VA_ARGS__

// usage example:
/*
ADD_SYNTHETIC_PROPERTY_TO_CLASS(NSObject, NSString *, mySyntheticNameString, setMySyntheticNameString, RETAIN_NONATOMIC)
ADD_SYNTHETIC_PROPERTY_TO_CLASS(NSObject, PACKED_ARG(NSDictionary<NSString *, NSNumber *> *), mySyntheticNameString, setMySyntheticNameString, RETAIN_NONATOMIC)
*/
