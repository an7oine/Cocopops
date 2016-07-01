//
//  2016 Magna cum laude. PD
//

#import "UIImageView+PDFSupport.h"

@implementation UIImageView (PDFSupport)

- (instancetype)initWithPDFData:(NSData *)pdfData pageNumber:(NSInteger)pageNumber ppi:(CGFloat)ppi
{
	CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)pdfData);
	CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
	CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, pageNumber);
	
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	CGSize targetSize = CGSizeMake(CGRectGetWidth(cropBox) * (ppi? ppi / 72.0f : 1.0f), CGRectGetHeight(cropBox) * (ppi? ppi / 72.0f : 1.0f));
	
	CGColorSpaceRef colourspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, targetSize.width, targetSize.height, 8, 0, colourspace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
	
	CGAffineTransform transform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, (CGRect){ CGPointZero, targetSize }, 0, YES);
	CGContextConcatCTM(context, transform);
	
	CGContextDrawPDFPage(context, page);
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationUp];
	
	CGImageRelease(imageRef);
	CGContextRelease(context);
	CGColorSpaceRelease(colourspace);
	CGPDFDocumentRelease(pdfDocument);
	CGDataProviderRelease(dataProvider);
	
	return [self initWithImage:image];
}

@end
