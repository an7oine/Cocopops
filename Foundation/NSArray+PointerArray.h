//
//  2015 Magna cum laude. PD
//


#import <Foundation/Foundation.h>

@interface NSArray (PointerArray)

// 'malloc' a array, fill it with self's objects (as __bridge void *), then sort the pointers into ascending order;
// return by reference
- (void)getSortedPointers:(void ***)pointers count:(size_t *)count;

// 'malloc' a new array, fill it with the given existing pointers + self's objects, then sort everything again;
// return by reference
- (void)combineWithSortedPointers:(void ***)pointers count:(size_t *)count;

// 'malloc' a new array, fill it with the given pointers, then return the copy
+ (void **)duplicateSortedPointers:(void **)pointers count:(size_t)count;

// check whether a given object is pointed to within the given (__bridge void *) pointers
+ (BOOL)sortedPointers:(void **)pointers count:(size_t)count containObject:(id)obj;

@end
