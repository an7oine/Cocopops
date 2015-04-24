//
//  2015 Magna cum laude. PD
//

#import "NSArray+PointerArray.h"

@implementation NSArray (PointerArray)

- (void)getSortedPointers:(void ***)pointers count:(size_t *)count
{
	*count = self.count;
	*pointers = malloc(sizeof (void *) * *count);
	size_t pointerIndex=0;
	for (id obj in self)
		(*pointers)[pointerIndex++] = (__bridge void *)obj;
	qsort_b(*pointers, *count, sizeof (void *), ^int(const void *a, const void *b)
	{
		return (int)(*(const void **)a - *(const void **)b);
	});
}

- (void)combineWithSortedPointers:(void ***)pointers count:(size_t *)count
{
	void **combinedPointers = malloc(sizeof (void *) * (*count + self.count));
	memcpy(combinedPointers, *pointers, sizeof (void *) * *count);
	size_t pointerIndex = *count;
	*pointers = combinedPointers;
	*count = *count + self.count;
	for (id obj in self)
		combinedPointers[pointerIndex++] = (__bridge void *)obj;
	qsort_b(*pointers, *count, sizeof (void *), ^int(const void *a, const void *b)
	{
		return (int)(*(const void **)a - *(const void **)b);
	});
}

+ (void **)duplicateSortedPointers:(void **)pointers count:(size_t)count
{
	void **duplicatedPointers = malloc(sizeof (void *) * count);
	memcpy(duplicatedPointers, pointers, sizeof (void *) * count);
	return duplicatedPointers;
}

+ (BOOL)sortedPointers:(void **)pointers count:(size_t)count containObject:(id)obj
{
	size_t i=0;
	while (i < count)
		if (pointers[i] == (__bridge void *)obj)
			return YES;
		else if (pointers[i] > (__bridge void *)obj)
			return NO;
		else
			i++;
	return NO;
}

@end
