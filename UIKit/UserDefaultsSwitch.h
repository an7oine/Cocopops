//
//  2016 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

/**
A switch that will automatically bind both ways with a single @c BOOL key in @c NSUserDefaults.standardUserDefaults

Assign a key to @c userDefaultsKeyPath to start monitoring that key for changes in user defaults,
 and to propagate any state changes of @c self.on there
 */
@interface UserDefaultsSwitch : UISwitch

@property (nonatomic) NSString *userDefaultsKeyPath;

- (instancetype)initWithKeyPath:(NSString *)keyPath;
+ (instancetype)switchWithKeyPath:(NSString *)keyPath;

@end
