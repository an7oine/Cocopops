//
//  2014 Magna cum laude. PD
//

#import "NSData+RandomData.h"

@implementation NSData (RandomData)

+ (instancetype)randomDataWithSize:(size_t)size
{
	NSMutableData *result = [[NSMutableData alloc] initWithLength:size];
	NSAssert(SecRandomCopyBytes(kSecRandomDefault, size, result.mutableBytes) == 0, @"Failure in SecRandomCopyBytes: %d", errno);
	return result;
}

@end
