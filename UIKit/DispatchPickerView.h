//
//  2015 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface DispatchPickerView : UIPickerView

- (NSInteger)addChoiceWithTitle:(NSString *)title block:(void (^)(NSInteger row))block;

- (void (^)(NSInteger))blockWithRow:(NSInteger)row;

@end
