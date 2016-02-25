//
//  UITMoveScrollViewController.h
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

@interface MMSProfileImagePicker : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIEdgeInsets frameInsets;
@property (nonatomic)CGFloat minimumZoomScale;
@property (nonatomic)CGFloat maxiumuZoomScale;
@property (nonatomic)float   overlayOpacity;
@property (strong, nullable)UIColor* backgroundColor;
@property (strong, nullable)UIColor* foregroundColor;
//@property (strong, nullable)UIImage* image;
@property (nullable, nonatomic, weak)id <MMSProfileImagePickerDelegate> delegate;

-(void)presentEditScreen:(UIViewController* _Nonnull)vc withImage:(UIImage* _Nonnull)image;
-(void)selectFromPhotoLibrary:(UIViewController* _Nonnull)vc;
-(void)selectFromCamera:(UIViewController* _Nonnull)vc;

@end
