//
//  NSArray+Deduplicate.h
//  i18XX
//
//  Created by Antti Hautaniemi on 17.4.2015.
//  Copyright (c) 2015 Magna cum laude. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Deduplicate)

- (NSArray *)arrayByRemovingDuplicates;
- (NSArray *)arrayByRemovingAdjacentDuplicates;

@end
