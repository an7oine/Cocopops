//
//  UIApplication+GetFirstResponder.h
//  i18XX
//
//  Created by Antti Hautaniemi on 11.5.2015.
//  Copyright (c) 2015 Magna cum laude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (GetFirstResponder)

- (id)firstResponder;
- (CGSize)inputViewSize;

@end
