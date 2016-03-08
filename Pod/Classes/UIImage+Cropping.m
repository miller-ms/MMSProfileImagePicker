//
//  UIImage+Cropping.m
//
//
//  Copyright © 2016 William Miller, http://millermobilesoft.com/
//  email:<support@millermobilesoft.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UIImage+Cropping.h"
@import CoreFoundation;


// static inline double radians (double degrees) {return degrees * M_PI/180;}


@implementation UIImage (Cropping)



+(CGSize)scaleSize:(CGSize)fromSize toSize:(CGSize)toSize {
    
    CGSize scaleSize = CGSizeZero;
    
    // if the wideth is the shorter dimension
    if (toSize.width < toSize.height) {
        
        if (fromSize.width >= toSize.width) {  // give priority to width if it is larger than the destination width
            
            scaleSize.width = roundf(toSize.width);
            
            scaleSize.height = roundf(scaleSize.width * fromSize.height / fromSize.width);
            
        } else if (fromSize.height >= toSize.height) {  // then give priority to height if it is larger than destination height
            
            scaleSize.height = roundf(toSize.height);
            
            scaleSize.width = round(scaleSize.height * fromSize.width / fromSize.height);
            
        } else {  // otherwise the source size is smaller in all directions.  Scale on width
            
            scaleSize.width = roundf(toSize.width);
            
            scaleSize.height = roundf(scaleSize.width * fromSize.height / fromSize.width);
            
            if (scaleSize.height > toSize.height) { // but if the new height is larger than the destination then scale height
                
                scaleSize.height = roundf(toSize.height);
                
                scaleSize.width = roundf(scaleSize.height * fromSize.width / fromSize.height);
            }
            
        }
    } else {  // else height is the shorter dimension
        
        if (fromSize.height >= toSize.height) {  // then give priority to height if it is larger than destination height
            
            scaleSize.height = roundf(toSize.height);
            
            scaleSize.width = round(scaleSize.height * fromSize.width / fromSize.height);
            
        } else if (fromSize.width >= toSize.width) {  // give priority to width if it is larger than the destination width
            
            scaleSize.width = roundf(toSize.width);
            
            scaleSize.height = roundf(scaleSize.width * fromSize.height / fromSize.width);
            
            
        } else {  // otherwise the source size is smaller in all directions.  Scale on width
            
            scaleSize.width = roundf(toSize.width);
            
            scaleSize.height = roundf(scaleSize.width * fromSize.height / fromSize.width);
            
            if (scaleSize.height > toSize.height) { // but if the new height is larger than the destination then scale height
                
                scaleSize.height = roundf(toSize.height);
                
                scaleSize.width = roundf(scaleSize.height * fromSize.width / fromSize.height);
            }
            
        }
        
    }
    
    return scaleSize;
}

/** scale bitmap to size
 *  returns an UIImage scaled to the input dimensions. Oftentimes the underlining CGImage does not match the orientation of the UIImage. This routing scales the UIImage dimensions not the CGImage's, and so it swaps the height and width of the scale size when it detects the UIImage is oriented differently.
 *
 *  @param scaleSize the dimensions to scale the bitmap to.
 *
 *  @return A reference to a uimage created from the scaled bitmap
 */
-(UIImage*)scaleBitmapToSize:(CGSize)scaleSize

{
    
    /* round the size of the underlying CGImage and the input size.
     */
    scaleSize = CGSizeMake(round(scaleSize.width), round(scaleSize.height));
    
    /* if the underlying CGImage is oriented differently than the UIImage then swap the width and height of the scale size. This method assumes the size passed is a request on the UIImage's orientation.
     */
    if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight) {
            
        scaleSize = CGSizeMake(round(scaleSize.height), round(scaleSize.width));
    }
    
    /* Create a bitmap context in the dimensions of the scale size and draw the underlying CGImage into the context.
     */
    CGContextRef context = CGBitmapContextCreate(nil, scaleSize.width, scaleSize.height, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    
    
    UIImage* returnImg;
    
    if (context != NULL) {
        
        CGContextDrawImage(context, CGRectMake(0, 0, scaleSize.width, scaleSize.height), self.CGImage);
        
        /* realize the CGImage from the context.
         */
        CGImageRef imgRef = CGBitmapContextCreateImage(context);
        
        CGContextRelease(context);  // context is no longer needed so release it.
        
        /* realize the CGImage into a UIImage.
         */
        returnImg = [UIImage imageWithCGImage:imgRef];
        
        CGImageRelease(imgRef);  // release the CGImage as it is no longer needed.

    } else {
        
        /* context creation failed, so return a copy of the image, and log the error.
         */
        NSLog (@"NULL Bitmap Context in scaleBitmapToSize");
        
        returnImg = [UIImage imageWithCGImage:self.CGImage];
    }
    

    return returnImg;
    
}

/* transposeCropRect:fromBound:toBound transposes the origin of the crop rectangle to match the orientation of the underlying CGImage. For some orientations, the height and width are swaped.
*/
-(CGRect)transposeCropRect:(CGRect)cropRect fromBound:(CGRect)fromRect toBound:(CGRect)toRect {
    
    CGFloat scale = toRect.size.width / fromRect.size.width;
    
    return CGRectMake(round(cropRect.origin.x * scale), round(cropRect.origin.y*scale), round(cropRect.size.width*scale), round(cropRect.size.height*scale));
    
}

/* orientCropRect:inDimension: transposes the origin of the crop rectangle to match the orientation of the underlying CGImage. For some orientations, the height and width are swaped.
 */
-(CGRect)transposeCropRect:(CGRect)cropRect inDimension:(CGSize)boundSize forOrientation:(UIImageOrientation)orientation{
    
    CGRect transposedRect = cropRect;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            transposedRect.origin.x = boundSize.height - (cropRect.size.height + cropRect.origin.y);
            transposedRect.origin.y = cropRect.origin.x;
            transposedRect.size = CGSizeMake(cropRect.size.height, cropRect.size.width);
            break;
            
        case UIImageOrientationRight:
            transposedRect.origin.x = cropRect.origin.y;
            transposedRect.origin.y = boundSize.width - (cropRect.size.width + cropRect.origin.x);
            transposedRect.size = CGSizeMake(cropRect.size.height, cropRect.size.width);
            break;
            
        case UIImageOrientationDown:
            transposedRect.origin.x = boundSize.width - (cropRect.size.width + cropRect.origin.x);
            transposedRect.origin.y = boundSize.height - (cropRect.size.height + cropRect.origin.y);
            break;

        case UIImageOrientationUp:
            break;

        case UIImageOrientationDownMirrored:
            transposedRect.origin.x = cropRect.origin.x;
            transposedRect.origin.y = boundSize.height - (cropRect.size.height + cropRect.origin.y);
            break;

        case UIImageOrientationLeftMirrored:
            transposedRect.origin.x = cropRect.origin.y;
            transposedRect.origin.y = cropRect.origin.x;
            transposedRect.size = CGSizeMake(cropRect.size.height, cropRect.size.width);
            break;
            
        case UIImageOrientationRightMirrored:
            transposedRect.origin.x = boundSize.height - (cropRect.size.height + cropRect.origin.y);
            transposedRect.origin.y = boundSize.width - (cropRect.size.width + cropRect.origin.x);
            transposedRect.size = CGSizeMake(cropRect.size.height, cropRect.size.width);            
            break;
            
        case UIImageOrientationUpMirrored:
            transposedRect.origin.x = boundSize.width - (cropRect.size.width + cropRect.origin.x);
            transposedRect.origin.y = cropRect.origin.y;
            break;
            
            
        default:
            break;
    }
    
    return transposedRect;
}
/* cropRectangle:inFrame returns a new UIImage cut from the cropArea of the underlying image.  It first scales the underlying image to the scale size before cutting the crop area from it. The returned CGImage is in the dimensions of the cropArea and it is oriented the same as the underlying CGImage as is the imageOrientation.
 */
-(UIImage*)cropRectangle:(CGRect)cropRect inFrame:(CGSize)frameSize {
    
    frameSize = CGSizeMake(round(frameSize.width), round(frameSize.height));
    
    /* resize the image to match the zoomed content size
     */
    UIImage* img = [self scaleBitmapToSize:frameSize];
    
    /* crop the resized image to the crop rectangel.
     */
    CGImageRef cropRef = CGImageCreateWithImageInRect(img.CGImage, [self transposeCropRect:cropRect inDimension:frameSize forOrientation:self.imageOrientation]);
    
    UIImage* croppedImg = [UIImage imageWithCGImage:cropRef scale:1.0 orientation:self.imageOrientation];
    
    return croppedImg;
    
}

@end
