//
//  NSArray+Deduplicate.m
//  i18XX
//
//  Created by Antti Hautaniemi on 17.4.2015.
//  Copyright (c) 2015 Magna cum laude. All rights reserved.
//

#import "NSArray+Deduplicate.h"

@implementation NSArray (Deduplicate)

- (NSArray *)arrayByRemovingDuplicates
{
	NSMutableArray *result = [NSMutableArray new];
	for (id obj in self)
		if (! [result containsObject:obj])
			[result addObject:obj];
	return result;
}

- (NSArray *)arrayByRemovingAdjacentDuplicates
{
	NSMutableArray *result = [NSMutableArray new];
	id lastObj = nil;
	for (id obj in self)
		if (lastObj != obj)
			[result addObject:(lastObj = obj)];
	return result;
}

@end
