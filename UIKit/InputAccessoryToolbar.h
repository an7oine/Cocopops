//
//  2014 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

typedef enum { kToolbarTitle=1, kToolbarArrows=2, kToolbarClear=4, kToolbarDone=8 } toolbarContent_t;

@interface InputAccessoryToolbar : UIToolbar

@property (readonly) toolbarContent_t content;

@property (readonly) UIBarButtonItem *titleItem;
@property (readonly) UIBarButtonItem *prevItem, *nextItem;
@property (readonly) UIBarButtonItem *clearItem, *doneItem;

- (instancetype)initWithFrame:(CGRect)frame content:(toolbarContent_t)content;

@end
