//
//  2014 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

// note: link against libz

@interface NSData (ZLibCompression)

// compress with zlib, prepend uncompressed data length in 64 bits
- (NSData *)deflate;

// read uncompressed length, then uncompress with zlib
- (NSData *)inflate;

@end
