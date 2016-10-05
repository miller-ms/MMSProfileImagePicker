//
//  MMSProfileImagePickerDelegate
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
#import "MMSProfileImagePickerDelegate.h"
@import MMSCameraViewController;

@interface MMSProfileImagePicker : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MMSCameraViewDelegate>

/**
 *  Determines how small the image can be scaled.  The default is 1 i.e. it can be made smaller than original.
 */
@property (nonatomic)CGFloat minimumZoomScale;

/**
 *  Determines how large the image can be scaled.  The default is 10.
 */
@property (nonatomic)CGFloat maximumZoomScale;

/**
 *  A value from 0 to 1 to control how brilliant the image shows through the area outside of the crop circle.
 *  1 is completely opaque and 0 is completely transparent.  The default is .6.
 */
@property (nonatomic)float   overlayOpacity;

/**
 *  The background color of the edit screen.  The default is black.
 */
@property (strong, nullable)UIColor* backgroundColor;

/**
 *  The foreground color of the text on the edit screen. The default is white.
 */
@property (strong, nullable)UIColor* foregroundColor;

/**
 *  The delegate receives notifications when the user has selected an image or exits image selection.
 */
@property (nullable, nonatomic, weak)id <MMSProfileImagePickerDelegate> delegate;

/** Edits an Image
 *
 *  Presents a screen to resize and position the passed image within a circular crop region.
 *
 *  @param vc    The view controller to present the edit screen from.
 *  @param image The image to edit
 */
-(void)presentEditScreen:(UIViewController* _Nonnull)vc withImage:(UIImage* _Nonnull)image;

/** Select image from photo library
 *
 *  Presents the sequnence of screens to select an image from the device's photo library.
 *
 *  @param vc The view controller to present the library selection screen from.
 */
-(void)selectFromPhotoLibrary:(UIViewController* _Nonnull)vc;

/** Select image from the camera
 *
 *  Presents the camera for positioning a scene and acquiring the image.
 *
 *  @param vc The view controller to present the camera from.
 */
-(void)selectFromCamera:(UIViewController* _Nonnull)vc;

@end
