//
//  2015 Magna cum laude. PD
//

#import "DispatchPickerView.h"


@interface DispatchPickerDelegate : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) id <UIPickerViewDelegate> clientDelegate;
@property (nonatomic, readonly) NSMutableArray *choices;
@property (nonatomic, readonly) NSMutableDictionary *blockDictionary;
@end
@implementation DispatchPickerDelegate
@synthesize blockDictionary=_blockDictionary;
@synthesize choices=_choices;
- (NSMutableDictionary *)blockDictionary
{
	return _blockDictionary ?: (_blockDictionary = [NSMutableDictionary new]);
}
- (NSMutableArray *)choices
{
	return _choices ?: (_choices = [NSMutableArray new]);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return _choices.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return _choices[row]; }

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	void (^block)(NSInteger rowIndex) = self.blockDictionary[@( row )];
	if (block)
		block(row);
	[self.clientDelegate pickerView:pickerView didSelectRow:row inComponent:component];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [super respondsToSelector:aSelector] || [self.clientDelegate respondsToSelector:aSelector];
}
- (id)forwardingTargetForSelector:(SEL)aSelector { return self.clientDelegate; }
@end


@implementation DispatchPickerView
{
	DispatchPickerDelegate *_dispatchPickerDelegate;
}

#pragma mark - Delegate & Data Source

- (DispatchPickerDelegate *)dispatchPickerDelegate
{
	if (_dispatchPickerDelegate)
		return _dispatchPickerDelegate;
	_dispatchPickerDelegate = [[DispatchPickerDelegate alloc] init];
	[super setDelegate:_dispatchPickerDelegate];
	return _dispatchPickerDelegate;
}
- (id<UIPickerViewDelegate>)delegate { return self.dispatchPickerDelegate; }
- (void)setDelegate:(id<UIPickerViewDelegate>)delegate
{
	self.dispatchPickerDelegate.clientDelegate = delegate;
}
- (id<UIPickerViewDataSource>)dataSource { return self.dispatchPickerDelegate; }
- (void)setDataSource:(id<UIPickerViewDataSource>)dataSource { }


#pragma mark - Public methods

- (NSInteger)addChoiceWithTitle:(NSString *)title block:(void (^)(NSInteger))block
{
	NSInteger row = self.dispatchPickerDelegate.choices.count;
	self.dispatchPickerDelegate.choices[row] = title;
	self.dispatchPickerDelegate.blockDictionary[@( row )] = block;
	return row;
}

- (void (^)(NSInteger))blockWithRow:(NSInteger)row
{
	return self.dispatchPickerDelegate.blockDictionary[@( row )];
}

@end
