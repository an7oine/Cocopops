//
//  2017 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface DispatchBarButtonItem : UIBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(DispatchBarButtonItem *barButtonItem))handler;
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(DispatchBarButtonItem *barButtonItem))handler;

@end
