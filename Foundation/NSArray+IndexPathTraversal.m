//
//  2015 Magna cum laude. PD
//

#import "NSArray+IndexPathTraversal.h"

@implementation NSArray (IndexPathTraversal)

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger firstIndex = [indexPath indexAtPosition:0];
    if (firstIndex >= self.count)
        return nil;
    
    NSIndexPath *resultantPath = [NSIndexPath new];
    for (NSInteger i=1; i < indexPath.length; i++)
        resultantPath = [resultantPath indexPathByAddingIndex:[indexPath indexAtPosition:i]];
    
    NSArray *firstObject = self[firstIndex];
    if (resultantPath.length == 0)
        return firstObject;
    else if ([firstObject isKindOfClass:NSArray.class])
        return [firstObject objectAtIndexPath:resultantPath];
    else
        return nil;
}

@end
