//
//  2014 Magna cum laude. PD
//

#import <zlib.h>

#import "NSData+ZLibCompression.h"

@implementation NSData (ZLibCompression)

- (NSData *)deflate
{
	size_t compressedLength = compressBound(self.length);
	NSMutableData *compressedData = [[NSMutableData alloc] initWithLength:compressedLength];
	if (compress(compressedData.mutableBytes, &compressedLength, self.bytes, self.length) == Z_OK)
	{
		compressedData.length = compressedLength;
		
		uint64_t inflatedLength = self.length;
		NSMutableData *resultData = [NSMutableData dataWithBytes:&inflatedLength length:sizeof (uint64_t)];
		[resultData appendData:compressedData];
		
		return resultData;
	}
	else
		return nil;
}
- (NSData *)inflate
{
	size_t inflatedLength = (size_t) *((const uint64_t *)self.bytes);
	NSData *compressedData = [self subdataWithRange:NSMakeRange(sizeof (uint64_t), self.length-sizeof (uint64_t))];
	
	NSMutableData *result = [[NSMutableData alloc] initWithLength:inflatedLength];
	
	if (uncompress(result.mutableBytes, &inflatedLength, compressedData.bytes, compressedData.length) == Z_OK)
	{
		result.length = inflatedLength;
		return result;
	}
	else
		return nil;
}

@end
