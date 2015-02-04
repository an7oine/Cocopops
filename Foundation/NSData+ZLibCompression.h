//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

// note: link against libz

@interface NSData (ZLibCompression)

- (NSData *)deflate; // decode uncompressed length with 8 bytes, followed by zlib compression result
- (NSData *)inflate; // encode uncompressed length in 8 first bytes, with zlib compress result following

@end
