//
//  2015 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSSet (RemoveObject)

- (NSSet *)setByRemovingObject:(id)object;
- (NSSet *)setByRemovingObjectsInSet:(NSSet *)set;

@end
