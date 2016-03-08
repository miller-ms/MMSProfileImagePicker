//
//  MMSProfileImagePickerDelegate.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MMSProfileImagePicker;

@protocol MMSProfileImagePickerDelegate <NSObject>

/**
 *  The user canceled out of the image selection operation.
 *
 *  @param picker Reference to the Profile Picker
 */
-(void)mmsImagePickerControllerDidCancel:(MMSProfileImagePicker * _Nonnull)picker;

/**
 *  The user completed the operation of either editing, selecting from photo library, or capturing from the camera.  The dictionary uses the editing information keys used in UIImagePickerController.
 *
 *  @param picker Reference to profile picker that completed selection.
 *  @param info   A dictionary containing the original image and the edited image, if an image was picked; The dictionary also contains any relevant editing information. .
 */
-(void)mmsImagePickerController:(MMSProfileImagePicker* _Nonnull)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*_Nonnull)info;

@end
