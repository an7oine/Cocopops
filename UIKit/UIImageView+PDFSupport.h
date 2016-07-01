//
//  2016 Magna cum laude. PD
//

#import <UIKit/UIKit.h>

@interface UIImageView (PDFSupport)

- (instancetype)initWithPDFData:(NSData *)pdfData pageNumber:(NSInteger)pageNumber ppi:(CGFloat)ppi;
- (void)setPDFData:(NSData *)pdfData pageNumber:(NSInteger)pageNumber ppi:(CGFloat)ppi;

@end
