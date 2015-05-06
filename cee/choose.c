//
//  2015 Magna cum laude. PD
//

#include "choose.h"
#include <stdlib.h>
#include <string.h>

int choose(const void ***buckets, const size_t *itemCounts, const size_t bucketCount, int (^block)(const void **items, const size_t itemCount))
{
	if (bucketCount == 0)
		return block(NULL, 0);
	const void **prependedItems = (const void **)malloc(sizeof(void *) * bucketCount);
	int result = 1;
	for (size_t i=0; i < itemCounts[0]; i++)
	{
		prependedItems[0] = buckets[0][i];
		if (! choose(buckets+1,itemCounts+1,bucketCount-1, ^int(const void **items, const size_t itemCount)
		{
			memcpy(prependedItems+1, items, sizeof(void *) * itemCount);
			return block(prependedItems, itemCount+1);
		}))
		{
			result = 0;
			break;
		}
	}
	free(prependedItems);
	return result;
}