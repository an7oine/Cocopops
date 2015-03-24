//
//  2015 Magna cum laude. PD
//

#include "search.h"

size_t l_inv_bsearch_le(const long *base, long key, size_t skip, size_t nelem)
{
	if (nelem == 0)
		return skip+nelem;
	size_t midpoint = skip + (nelem>>1);
	if (base[midpoint] > key)
		return l_inv_bsearch_le(base, key, midpoint+1, nelem - (nelem>>1) - 1);
	else if (midpoint>0 && base[midpoint-1]<=key)
		return l_inv_bsearch_le(base, key, skip, (nelem>>1));
	else
		return midpoint;
}
