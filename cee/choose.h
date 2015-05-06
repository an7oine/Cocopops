//
//  2015 Magna cum laude. PD
//

#ifndef __Cocopops__choose__
#define __Cocopops__choose__

#include <stddef.h> // for size_t

// Enumerate ways to select one 'item' from each 'bucket', where number of items in 'buckets[i]' is 'itemCount[i]'
// each such selection of 'items' is passed to 'block' along with the number of selected items (=='bucketCount')
// return 0 from 'block' to cancel rest of the processing, in which case 'permute' shall also return 0, and 1 otherwise
int choose(const void ***buckets, const size_t *itemCounts, const size_t bucketCount, int (^block)(const void **items, const size_t itemCount));

#endif /* defined(__Cocopops__choose__) */
