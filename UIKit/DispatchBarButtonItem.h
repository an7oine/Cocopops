//
//  2017 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface DispatchBarButtonItem : UIBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(void))handler;
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(void))handler;

@end
