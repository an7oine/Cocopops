//
//  UIApplication+KeyboardFrame.m
//  i18XX
//
//  Created by Antti Hautaniemi on 13.5.2015.
//  Copyright (c) 2015 Magna cum laude. All rights reserved.
//

#import "UIApplication+KeyboardFrame.h"

@implementation UIApplication (KeyboardFrame)

static CGRect _keyboardFrame = (CGRect){ (CGPoint){ 0.0f, 0.0f }, (CGSize){ 0.0f, 0.0f } };
- (CGRect)keyboardFrame { return _keyboardFrame; }

+ (void)load
{
	[NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *note)
	{
		_keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	}];
	[NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note)
	{
		_keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	}];
	[NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification *note)
	{
		_keyboardFrame = CGRectZero;
	}];
}

@end
