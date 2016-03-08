//
//  UIImage+Cropping.h
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

#import <UIKit/UIKit.h>

@interface UIImage (Cropping)

/** scale size
 *  calculates a return size by aspect scaling the fromSize to fit within the destination size while giving priority to the width or height depending on which preference will maintain both the return width and height within the destination ie the return size will return a new size where both width and height are less than or equal to the destinations.
 *
 *  @param fromSize Size to be transforme
 *  @param toSize   Destination size
 *
 *  @return Aspect scaled size
 */
+(CGSize)scaleSize:(CGSize)fromSize toSize:(CGSize)toSize;

/** crop rectangle
 *  returns a new UIImage cut from the cropArea of the underlying image.  It first scales the underlying image to the scale size before cutting the crop area from it. The returned CGImage is in the dimensions of the cropArea and it is oriented the same as the underlying CGImage as is the imageOrientation.
 *
 *  @param cropArea  the rectangle with in the frame size to crop.
 *  @param frameSize The size of the frame that is currently showing the image
 *
 *  @return A UIImage cropped to the input dimensions and oriented like the UIImage.
 */
-(UIImage*)cropRectangle:(CGRect)cropArea inFrame:(CGSize)frameSize;

/**
 * transposeCropRect:fromBound:toBound transposes the origin of the crop rectangle to match the orientation of the underlying CGImage. For some orientations, the height and width are swaped.
 *
 *  @param cropRect The crop rectangle as layed out on the screen.
 *  @param fromRect The rectangle the crop rect sits inside.
 *  @param toRect   The rectangle the crop rect will be removed from
 *
 *  @return The crop rectangle scaled to the rectangle.
 */
-(CGRect)transposeCropRect:(CGRect)cropRect fromBound:(CGRect)fromRect toBound:(CGRect)toRect;


@end
