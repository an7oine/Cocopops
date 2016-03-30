//
//  2016 Magna cum laude. PD
//

#import "UserDefaultsSwitch.h"

@implementation UserDefaultsSwitch

- (instancetype)initWithKeyPath:(NSString *)keyPath
{
	if (! (self = [super initWithFrame:CGRectZero]))
		return nil;
	self.userDefaultsKeyPath = keyPath;
	return self;
}

+ (instancetype)switchWithKeyPath:(NSString *)keyPath
{
	return [[self alloc] initWithKeyPath:keyPath];
}

- (void)dealloc
{
	self.userDefaultsKeyPath = nil;
}

- (void)setUserDefaultsKeyPath:(NSString *)userDefaultsKeyPath
{
	if (_userDefaultsKeyPath)
		[NSUserDefaults.standardUserDefaults removeObserver:self forKeyPath:_userDefaultsKeyPath];
	_userDefaultsKeyPath = userDefaultsKeyPath;
	if (_userDefaultsKeyPath)
	{
		[self removeTarget:self action:@selector(onStateDidChange:) forControlEvents:UIControlEventValueChanged];
		[NSUserDefaults.standardUserDefaults addObserver:self forKeyPath:_userDefaultsKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)UserDefaultsSwitch.class];
		[self addTarget:self action:@selector(onStateDidChange:) forControlEvents:UIControlEventValueChanged];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if (context != (__bridge void *)UserDefaultsSwitch.class)
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	else if ([keyPath isEqualToString:self.userDefaultsKeyPath])
		self.on = [change[NSKeyValueChangeNewKey] boolValue];
}

- (void)onStateDidChange:(id)sender
{
	[NSUserDefaults.standardUserDefaults setBool:self.on forKey:self.userDefaultsKeyPath];
}

@end
