//
//  2014 Magna cum laude. PD
//

#import "NSData+RandomData.h"

@implementation NSData (RandomData)

+ (instancetype)randomDataWithSize:(size_t)size
{
	NSMutableData *result = [[NSMutableData alloc] initWithLength:size];
	SecRandomCopyBytes(kSecRandomDefault, size, result.mutableBytes);
	return result;
}

@end
