//
//  UIApplication+GetFirstResponder.m
//  i18XX
//
//  Created by Antti Hautaniemi on 11.5.2015.
//  Copyright (c) 2015 Magna cum laude. All rights reserved.
//

#import "UIApplication+GetFirstResponder.h"

@implementation UIApplication (GetFirstResponder)

- (id)firstResponder
{
	__block id result = nil;
	[self sendAction:@selector(identifySelfUsingBlock:) to:nil from:^(id firstResponder){ result = firstResponder; } forEvent:nil];
	return result;
}
- (void)identifySelfUsingBlock:(void (^)(id firstResponder))block { block(self); }

- (CGSize)inputViewSize
{
	id firstResponder = self.firstResponder;
	return CGSizeMake([firstResponder inputView].frame.size.width, [firstResponder inputView].frame.size.height + [firstResponder inputAccessoryView].frame.size.height);
}

@end
