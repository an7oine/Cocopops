//
//  2016 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSArray (Patchworks)

/**
For an (order-insensitive) array of (direction-insensitive) arrays of nodes of type @c id, enumerate all (direction-sensitive) patchworks made up of contiguous fragments of the member arrays, adjoined at common nodes.

Each member array is guaranteed to appear in the results both as-is and in reverse order, as are all subarrays beginning at the head, and all reverse-order subarrays beginning at the tail. Note that for a collection of completely disjoint arrays, nothing beyond that will appear.

Example:
@code
NSArray *array = @[
 @[ @"a", @"c", @"e" ],
 @[ @"f", @"e", @"d" ],
 @[ @"b", @"f", @"j" ] ];
[array enumeratePatchworksUsingBlock:BOOL^(NSArray *patchwork)
{
	NSLog(@"%@", [patchwork componentsJoinedByString:@"-"]);
}];
@endcode
Output (excerpt):
@code
...
a-c-e-d
a-c-e-f-b
a-c-e-f-j
j-f-e-d
...
@endcode

@param block
	Handler invoked for each result found. Return @c YES to continue the enumeration or @c NO to abort.
 */
- (void)enumeratePatchworksUsingBlock:(BOOL (^)(NSArray *patchwork))block;

@end
