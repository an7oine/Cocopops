//
//  2016 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TVPickerViewDataSource, TVPickerViewDelegate;

/**
An in-place tvOS counterpart implementation for stock UIPickerView
 */
__IOS_PROHIBITED __TVOS_AVAILABLE(9.0) @interface TVPickerView : UIView

@property (nullable, nonatomic, weak) id<TVPickerViewDataSource> dataSource;
@property (nullable, nonatomic, weak) id<TVPickerViewDelegate> delegate;

@property (nonatomic) NSInteger preferredFocusedComponent;

@property (nonatomic, readonly) NSInteger numberOfComponents;
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

- (NSInteger)selectedRowInComponent:(NSInteger)component;

@end

/**
tvOS version of the UIPickerView data source protocol
 */
__IOS_PROHIBITED __TVOS_AVAILABLE(9.0) @protocol TVPickerViewDataSource<NSObject>
@required
- (NSInteger)numberOfComponentsInPickerView:(TVPickerView *)pickerView;
- (NSInteger)pickerView:(TVPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
@end

/**
tvOS version of the UIPickerView delegate protocol
 */
__IOS_PROHIBITED __TVOS_AVAILABLE(9.0) @protocol TVPickerViewDelegate<NSObject>
@optional
- (CGFloat)pickerView:(TVPickerView *)pickerView widthForComponent:(NSInteger)component;
- (CGFloat)pickerView:(TVPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

- (nullable NSString *)pickerView:(TVPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (nullable NSAttributedString *)pickerView:(TVPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (void)pickerView:(TVPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (void)pickerViewDidFinish:(TVPickerView *)pickerView;
@end

NS_ASSUME_NONNULL_END
