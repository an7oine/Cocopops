//
//  2014 Magna cum laude. PD
//

#import "LinedSectionsFlowLayout.h"

// A Flow Layout enhanced to lay out overlapping items in a well-defined order
// specifically, so that ones further down and to the left appear on top
// note: all items will still be on top of any Supplementary Views (where zIndex=0)

// Note: this and LinedSectionsFlowLayout are completely independent of each other,
// so their inheritance may just as well be reversed or completely dropped, if desired

@interface StackedFlowLayout : LinedSectionsFlowLayout
@end
