//
//  2015 Magna cum laude. PD
//

#ifndef __Cocopops__search__
#define __Cocopops__search__

#include <stddef.h> // for size_t

// Inverse (descending elements) Binary Search for the first Long value Less than or Equal to 'key'
size_t l_inv_bsearch_le(const long *base, long key, size_t skip, size_t nelem);

#endif /* defined(__Cocopops__search__) */
