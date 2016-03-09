//
//  2016 Magna cum laude. PD
//

#import "NSFileManager+DirectorySize.h"

@implementation NSFileManager (DirectorySize)

- (unsigned long long)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error
{
	NSDictionary *attributes = [self attributesOfItemAtPath:path error:error];
	if ([attributes[NSFileType] isEqualToString:NSFileTypeDirectory])
	{ 
		unsigned long long size = 0;
		for (NSString *subpath in [self subpathsOfDirectoryAtPath:path error:error])
			size += [self sizeOfDirectoryAtPath:[path stringByAppendingPathComponent:subpath] error:error];
		return size;
	}
	else 
		return [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
}

@end
