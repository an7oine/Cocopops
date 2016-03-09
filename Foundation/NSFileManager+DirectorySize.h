//
//  2016 Magna cum laude. PD
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DirectorySize)

- (unsigned long long)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

@end
