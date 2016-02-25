//
//  UITMoveScrollViewController.m
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

#import "MMSProfileImagePickerDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Cropping.h"
#import "MMSProfileImagePicker.h"
#import "MMSProfilePickerPrivateDelegateController.h"
@import AVFoundation;
@import CoreMedia;
@import ImageIO;

const CGFloat kOverlayInset = 10;

@implementation MMSProfileImagePicker

{
    
@private
    
    UIView* overlayView;  // displays the circle mask
    
    UIImageView* imageView;  // holds the image to be moved and cropped
    
    UIScrollView* scrollView;  // Holds the image for positioning and reasizing
    
    UIImage*  imageToEdit;  // Image passed to the edit screen.
    
    UILabel*  titleLabel;  // @"Move and Scale";
    
    UIButton* chooseButton;  // selects the image
    
    UIButton* cancelButton;  // cancels cropping
    
    CGRect cropRect;  // Rectangular area identifying the crop region
    
    UIImagePickerController* imagePicker;  // This class proxy's for the UIImagePickerController
    
    AVCaptureSession* session;  // Session for captureing a still image
    
    AVCaptureStillImageOutput* stillImageOutput;  //  holds the still image from the camera
    
    BOOL isDisplayFromPicker;  // Is displaying the photo picker

    BOOL isPresentingCamera;  // to determine if the crop screen is displayed from the camera path
    
    BOOL isSnapPhotoTargetAdded;  // true when the snap photo target has been replaced in the UIImagePickerController
    
    BOOL isPreparingStill;  // Set to true when camera has been initialized, so it only happens once.
    
    UIViewController* presentingVC;  // The view controller that presented the MMSImagePickerController
    
    MMSProfilePickerPrivateDelegateController* proxyVC;
        
    
}

@synthesize minimumZoomScale = _minimumZoomScale, maxiumuZoomScale=_maxiumuZoomScale;
@synthesize backgroundColor=_backgroundColor;
@synthesize foregroundColor=_foregroundColor;
@synthesize overlayOpacity=_overlayOpacity;
//@synthesize image=_image;

-(instancetype) init {
    
    self = [super init];
    
    _minimumZoomScale = 1;
    _maxiumuZoomScale = 10;
    _backgroundColor = [UIColor blackColor];
    _foregroundColor = [UIColor whiteColor];
    _overlayOpacity = 0.6;
    isDisplayFromPicker = NO;
    session = nil;
    stillImageOutput = nil;
    isPresentingCamera = NO;
    isPreparingStill = NO;
    isSnapPhotoTargetAdded = NO;
    imageToEdit = NULL;
    return self;
    
}

#pragma mark - View event handlers

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createSubViews];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self positionImageView];
    
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    

    if (isPresentingCamera) {
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        [proxyVC dismissViewControllerAnimated:NO completion:nil];
        
        isPresentingCamera = NO;
        
    } else if (isDisplayFromPicker) {
        
        [super dismissViewControllerAnimated:NO completion:nil];
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        isDisplayFromPicker = NO;
        
    } else {
        
        [super dismissViewControllerAnimated:flag completion:completion];

    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
}

/* supportedInterfaceOrientations: returns to support only the portrait orientation
 */
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

#pragma mark - View setup and initialization

/* positionImageView: positions the image view to fit within the center of the screen
 */

-(void)positionImageView {
    
    /* create the scrollView to fit within the physical screen size
     */
    CGRect screenRect = [UIScreen mainScreen].bounds;  // get the device physical screen dimensions
    
    imageView.image = imageToEdit;
    
    /* calculate the frame  of the image rectangle.  Depending on the orientation of the image and screen and the image's aspect ratio, either the height will fill the screen or the width. The image view is centered on the screen.  Either the height will fill the screen or the width. The dimension sized less than the enclosing rectangle will have equal insets above and below or left and right such that the image when unzooming can be positioned at the top bounder of the circle.
     */
    
    CGSize imageSize = [UIImage scaleSize:imageView.image.size toSize:screenRect.size];
    
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    imageView.frame = imageRect;
    
    // Compute crop rectangle.
    cropRect = [self centerSquareRectInRect:screenRect.size withInsets:UIEdgeInsetsMake(kOverlayInset, kOverlayInset, kOverlayInset, kOverlayInset)];
    
    // compute the scrollView's insets to center the crop rect on the screen and so that the image can be scrolled to the edges of the crop rectangle.
    UIEdgeInsets insets = [self insetsForImage:imageSize withFrame:cropRect.size inView:screenRect.size];
    
    scrollView.contentInset = insets;
    
    scrollView.contentSize = imageRect.size;
    
    scrollView.contentOffset = [self centerRect:imageRect inside:screenRect];
    
}

/* createSubViews: creates and positions the subviews to present functionality for moving and scaling an image having a circle overlay by default. It places the title, "Move and Scale" centered at the top of the screen.  A cancel button at the lower left corner and a choose button at the lower right corner.
 */

-(void) createSubViews {
    
    /* create the scrollView to fit within the physical screen size
     */
    CGRect screenRect = [UIScreen mainScreen].bounds;  // get the device physical screen dimensions
    
    scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    
    scrollView.backgroundColor = _backgroundColor;
    
    scrollView.delegate = self;
    
    scrollView.minimumZoomScale = _minimumZoomScale;    // content cannot shrink
    
    scrollView.maximumZoomScale = _maxiumuZoomScale;   // content can grow 10x original size
    
    self.view.backgroundColor = _backgroundColor;
    
    // resize the bottom view (z-order) to fit within the screen size and position it at the top left corner
    self.view.frame = CGRectMake(0,0, screenRect.size.width, screenRect.size.width);
    
    [self.view addSubview:scrollView];
    
    // create the image view with the image
    imageView = [[UIImageView alloc] initWithImage:imageToEdit];
    
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    [scrollView addSubview:imageView];
    
    /* create the overlay screen positioned over the entire screen having a square positioned at the center of the screen. The square side length is either the width or height of the screen size, whichever is smaller.  It's inset by 10 pixels.   Inside the square a circle is drawn to reveal the part of the image that will display in a circlewhen croped to the square's dimensions.
     */
    
    // Compute crop rectangle.
    cropRect = [self centerSquareRectInRect:screenRect.size withInsets:UIEdgeInsetsMake(kOverlayInset, kOverlayInset, kOverlayInset, kOverlayInset)];
    
    overlayView = [[UIScrollView alloc] initWithFrame:screenRect];
    
    overlayView.userInteractionEnabled = NO;
    
    CAShapeLayer* overlayLayer = [self createOverlay:cropRect bounds:screenRect];
    
    [overlayView.layer addSublayer:overlayLayer];
    
    [self.view addSubview:overlayView];

    /* add title, "Move and Scale" positioned at the top center of the screen
     */
    titleLabel = [self addTitleLabel:self.view];

    /* position the cancel button at the bottom left corner of the screen
     */
    cancelButton = [self addCancelButton:self.view action:@selector(cancel:)];
    
    /* position the choose button at the bottom right corner of the screen
     */
    chooseButton = [self addChooseButton:self.view action:@selector(choose:)];
    
}

/* addTitleLabel: adds the "Move and Scale" title centered at the top of the parent view.
 */
-(UILabel*)addTitleLabel:(UIView*)parentView {
    
    /*  define constants to create and position the title in the view.
     */
    const CGRect  kTitleFrame = {0.0f, 0.0f, 50.0f, 27.0f};
    const CGFloat kTopSpace = 25.0f;
    
    UILabel* label;
    
    label = [[UILabel alloc] initWithFrame:kTitleFrame];
    
    label.text = @"Move and Scale";
    
    label.textColor = _foregroundColor;
    
    [parentView addSubview:label];
    
    label.translatesAutoresizingMaskIntoConstraints = false;
    
    /* center the title in the view and position it a short distance from the top
     */
    [label.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor].active = YES;
    
    [label.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:kTopSpace].active = YES;
    
    return label;
}

/* addChooseButton: adds the button with the title "Choose" position at the bottom right corner of the parent view.
 */
-(UIButton*)addChooseButton:(UIView*)parentView action:(SEL _Nonnull)action {
    
    /* define constants to create and position the choose button on the bottom right corner of the parent view.
     */
    const CGRect kChooseFrame = {0.0f, 0.0f, 75.0f, 27.0f};
    const CGFloat kChooseRightSpace = 25.0f;
    const CGFloat kChooseBottomSpace = 50.0f;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = kChooseFrame;
    
    /* the button has a different title depending on whether it is displaying from the camera or the photo album picker and edit image.
     */
    
    if (isPresentingCamera) {
        
        [button setTitle:@"Use Photo" forState:UIControlStateNormal];
        
    } else {
        
        [button setTitle:@"Choose" forState:UIControlStateNormal];
    }

    [button setTitleColor:_foregroundColor forState:UIControlStateNormal];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [parentView addSubview:button];
    
    button.translatesAutoresizingMaskIntoConstraints = false;
    
    /* ancher the choose button to the bottom right corner of the parent view.
     */
    
    [button.topAnchor constraintEqualToAnchor:parentView.bottomAnchor constant:-kChooseBottomSpace].active = YES;
    
    [button.rightAnchor constraintEqualToAnchor:parentView.rightAnchor constant:-kChooseRightSpace].active = YES;
    
    return button;
    
}


/* addCancelButton: adds the button with the title "Cancel" position at the bottom left corner of the parent view.
 */

-(UIButton*)addCancelButton:(UIView*)parentView action:(SEL _Nonnull)action {
    
    /* define constants to create and position the choose button on the bottom left corner of the parent view.
     */
    const CGRect kCancelFrame = {0.0f, 0.0f, 50.0f, 27.0f};
    const CGFloat kCancelLeftSpace = 25.0f;
    const CGFloat kCancelBottomSpace = 50.0f;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = kCancelFrame;
    
    /* the button has a different title depending on whether it is displaying from the camera or the photo album picker and edit image.
     */
    if (isPresentingCamera) {
        
        [button setTitle:@"Retake" forState:UIControlStateNormal];
        
    } else {
        
        [button setTitle:@"Cancel" forState:UIControlStateNormal];
        
    }
    
    [button setTitleColor:_foregroundColor forState:UIControlStateNormal];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [parentView addSubview:button];
    
    button.translatesAutoresizingMaskIntoConstraints = false;
    
    /* ancher the cancel button to the bottom left corner of the parent view.
     */
    
    [button.topAnchor constraintEqualToAnchor:parentView.bottomAnchor constant:-kCancelBottomSpace].active = YES;
    
    [button.leftAnchor constraintEqualToAnchor:parentView.leftAnchor constant:kCancelLeftSpace].active = YES;
    
    return button;
    
}

/* viewForZoomingScrollView: the imageView is the view for zooming the scroll view.
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)sv withView:(UIView *)view atScale:(CGFloat)scale {
    
    UIEdgeInsets insets;
    
    insets = [self insetsForImage:scrollView.contentSize withFrame:cropRect.size inView:[UIScreen mainScreen].bounds.size];
    
    sv.contentInset = insets;
}

/* centerRect: retuns a rectangle's origin to position the inside rectangle centered within the enclosing one
 */

-(CGPoint)centerRect:(CGRect)insideRect inside:(CGRect)outsideRect {
    
    CGPoint upperLeft = CGPointZero;
    
    
    /* calculate the origin's y coordinate.
     */
    if (insideRect.size.height >= outsideRect.size.height) {
        
        upperLeft.y = roundf((insideRect.size.height - outsideRect.size.height) / 2);
        
    } else {
        
        upperLeft.y = -roundf((outsideRect.size.height - insideRect.size.height) / 2);
        
    }

    /* calculate the origin's x coordinate.
     */
    if (insideRect.size.width >= outsideRect.size.width) {
        
        upperLeft.x = roundf((insideRect.size.width - outsideRect.size.width) / 2);
        
    } else {
        
        upperLeft.x = -roundf((outsideRect.size.width - insideRect.size.width) / 2);
        
    }

    return upperLeft;
    
}

/* centerSquareRectInRect: creates a square with the shortest input dimensions less the insets, and positions the x and y coordinates such that it's center is the same center as would be the rectangle created from the input size and its origin at (0,0).
 */

-(CGRect)centerSquareRectInRect:(CGSize)layerSize withInsets:(UIEdgeInsets)inset {
    
    CGRect rect = CGRectZero;
    
    CGFloat length = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    
    /* if width is greater than height, swap the height and the width
     */
    
    if (layerSize.height < layerSize.width) {
        
        length = layerSize.height;
        
        x = (layerSize.width/2 - layerSize.height/2)+inset.left;
        
        y = inset.top;
        
    } else {
        
        
        length = layerSize.width;
        
        x = inset.left;
        
        y = (layerSize.height/2-layerSize.width/2)+inset.top;

    }

    rect = CGRectMake(x, y, length-inset.right-inset.left, length-inset.bottom-inset.top);

    
    return rect;
    
}

/* createOverlay: the overlay is the transparent view with the clear center to show how the image will appear when cropped. inBounds is the inside transparent crop region.  outBounds is the region that falls outside the inbound region and displays what's beneath it with dark transparency.
 */
-(CAShapeLayer*)createOverlay:(CGRect)inBounds bounds:(CGRect)outBounds{
    
    
    // create the circle so that it's diameter is the screen width and its center is at the intersection of the horizontal and vertical centers
    
    UIBezierPath *circPath;
    
    circPath = [UIBezierPath bezierPathWithOvalInRect:inBounds];

    // Create a rectangular path to enclose the circular path within the bounds of the passed in layer size.
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:outBounds cornerRadius:0];
    
    
    [rectPath appendPath:circPath];
    
    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    
    // add the circle path within the rectangular path to the shape layer.
    rectLayer.path = rectPath.CGPath;
    
    rectLayer.fillRule = kCAFillRuleEvenOdd;
    
    rectLayer.fillColor = _backgroundColor.CGColor;
    
    rectLayer.opacity = _overlayOpacity;
    
    return rectLayer;
    
}

/* insetsForImage:withFrame:inView: the goal of this routine is to calculate the insets so that the top and bottom of the image can align with the top and bottom of the frame when it is scrolled within the view.
 */
-(UIEdgeInsets)insetsForImage:(CGSize)imageSize withFrame:(CGSize)frameSize inView:(CGSize)viewSize {
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    UIEdgeInsets deltaInsets = UIEdgeInsetsZero;

    CGSize insideSize = frameSize;
    
    /* compute the delta top and bottom inset if image height is less than the frame.
     */

    if (imageSize.height < frameSize.height) {
        
        insideSize.height = imageSize.height;
        
        deltaInsets.top = deltaInsets.bottom = truncf((frameSize.height - insideSize.height)/2);
    }
    
    /* compute the delta left and right inset if image width is less than the frame.
     */

    if (imageSize.width < frameSize.width) {
        
        insideSize.width = imageSize.width;
        
        deltaInsets.left = deltaInsets.right = truncf((frameSize.width - insideSize.width)/2);
        
    }
    
    /*  compute the inset by adding the image inset with respect to the frame to the inset of the frame with respect to the view.
     */
    inset.bottom = inset.top = truncf(((viewSize.height - insideSize.height) / 2) + deltaInsets.top);
    
    inset.left = inset.right = truncf(((viewSize.width - insideSize.width) / 2) + deltaInsets.left);

    return inset;
}

#pragma mark - UINavigationControllerDelegate


/* navigationController:didShowViewController:animated: when the UIImagePickerController is presenting a camera to capture a still image, this routine removes the target for the button to taking the picture and adds a custom target.  This allows the class to display a customer move and scale screen for the still image.
 */

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera && !isSnapPhotoTargetAdded && isPresentingCamera) {
        
        UIView* bottomBarView = [viewController.view.subviews objectAtIndex:2];
        
        UIButton* buttonView = [bottomBarView.subviews objectAtIndex:8];
        
        [buttonView removeTarget:viewController.view action:NULL forControlEvents:UIControlEventTouchUpInside];
        
        [buttonView addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        isSnapPhotoTargetAdded = YES;

    }
    
}


#pragma mark - UIImagePickerControllerDelegate


/* imagePickerController:didFinishPickingMediaWithInfo: this routine calls the equivalent this class's custome delegate method.
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    UIImage* tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self editImage:tempImage];
    
//    [self.delegate mmsImagePickerController:self didFinishPickingMediaWithInfo:info];
    
}

/* imagePickerControllerDidCancel: this routine calls the equivalent this class's custome delegate method.
 */

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.delegate mmsImagePickerControllerDidCancel:self];
    
}


#pragma mark - action

/* takePhoto: called by the UIImagePickerController when the user presses the take photo button in the camera view.
 */

-(IBAction)takePhoto:(UIButton*)sender {
    
    [self prepareToCaptureStillImage];
    
    return;
    
}

/* choose: called when the user is finished with moving and scaling the image to select it as final.  It crops the image and sends the information to the delegate.
 */
-(IBAction)choose:(UIButton*)sender {
    
    UIImage* img;
    
    CGPoint cropOrigin;
    
    /* compute the crop rectangle based on the screens dimensions.
     */
    cropOrigin.x = truncf(scrollView.contentOffset.x + scrollView.contentInset.left);
    
    cropOrigin.y = truncf(scrollView.contentOffset.y + scrollView.contentInset.top);
    
    CGRect screenCropRect = CGRectMake(cropOrigin.x, cropOrigin.y, cropRect.size.width, cropRect.size.height);
    
    img = [imageView.image cropRectangle:screenCropRect inFrame:scrollView.contentSize];
    
    /* transpose the crop rectangle from the screen dimensions to the actual image dimensions.
     */
    CGRect imageCropRect = [img transposeCropRect:screenCropRect fromBound:CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height) toBound:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
    
    /* create the dictionary properties to pass to the delegate.
     */
    NSDictionary* info = @{UIImagePickerControllerEditedImage: img,
                           UIImagePickerControllerOriginalImage: imageView.image,
                           UIImagePickerControllerMediaType: (__bridge NSString*)kUTTypeImage,
                           UIImagePickerControllerCropRect: [NSValue valueWithCGRect:imageCropRect]};
    
    [self.delegate mmsImagePickerController:self didFinishPickingMediaWithInfo:info];
    
}

/* cancel: the user has decided to snap another photo if presenting the camera, to choose another image from the album if presenting the album, or to exit the move and scale when only using it to crop an image.
 */
-(IBAction)cancel:(UIButton*)sender {
    
    if (isDisplayFromPicker) {
        
        [imagePicker popViewControllerAnimated:NO];
        
    } else if (isPresentingCamera) {
        
        [imagePicker popViewControllerAnimated:NO];
        
    } else {
        
        [self.delegate mmsImagePickerControllerDidCancel:self];

    }
    
}

#pragma mark - Public Interface
/* presentEditScreen: presents the move and scale window for a supplied image.  This use case is for when all that's required is to crop an image not to select one from the camera or photo album before cropping.
 */

-(void)presentEditScreen:(UIViewController* _Nonnull)vc withImage:(UIImage* _Nonnull)image{
    
    isDisplayFromPicker = isPresentingCamera = NO;
    
    imageToEdit = image;
    
    presentingVC = vc;
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [presentingVC presentViewController:self animated:YES completion:nil];

}

/* editImage: presents the move and scale view initialized with the input image.  This is only to be called from the presentCamera and presentPhotoPicker workflows after the user has captured an image or selected one.
 */
-(void)editImage:(UIImage*)image {
    
    imageToEdit = image;
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [imagePicker setNavigationBarHidden:YES];
    
    [imagePicker pushViewController:self animated:NO];

}

/* selectFromPhotoLibrary: instantiates the UIImagePickerController object and configures it to present the photo library picker.
 */
-(void)selectFromPhotoLibrary:(UIViewController* _Nonnull)vc {

    imagePicker = [[UIImagePickerController alloc] init];

    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];

    imagePicker.allowsEditing = NO;
    
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    isDisplayFromPicker = YES;
    
    presentingVC = vc;
    
    imagePicker.delegate = self;
    
    [presentingVC presentViewController:imagePicker animated:YES completion:nil];
    

}

/* selectFromCamera: instantiates the UIImagePickerController object and configures it to present the camera.
 */

- (void)selectFromCamera:(UIViewController* _Nonnull)vc {

    // *** new code here
    
    isPresentingCamera = YES;
    
    imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.allowsEditing = NO;
    
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    proxyVC = [[MMSProfilePickerPrivateDelegateController alloc] initWithPicker:self];
    
    imagePicker.delegate = self;
    
    presentingVC = vc;
    
    [presentingVC presentViewController:proxyVC animated:NO completion:nil];
    
    [proxyVC presentViewController:imagePicker animated:YES completion:nil];
    
//    [presentingVC presentViewController:imagePicker animated:YES completion:nil];
    
    
}


#pragma mark - Camera setup and capture

/* prepareToCaptureStillImage: creates the objects necessary to capture a still image from the camera. There's a 1 second delay before acquiring the image from the camera.  This improves the quality of the acquired image.  Some have suggested the delay is required to give the camera time to complete it's initialization.
 */

-(void)prepareToCaptureStillImage {
    
    if (!isPreparingStill) {
    
        session = [[AVCaptureSession alloc] init];
    
        session.sessionPreset = AVCaptureSessionPresetHigh;
    
        [self captureInput:[self getCameraDevice]];
    
        stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
        NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG, AVVideoQualityKey : @1.0, AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel};
    
        [stillImageOutput setOutputSettings:outputSettings];
    
        [session addOutput:stillImageOutput];
        
        isPreparingStill = YES;
        
    }
    
    [session startRunning];
    
    /* give the camera some time to focus, energize the flash, and execute the capture before acquiring the image.
     */
    [NSTimer scheduledTimerWithTimeInterval:0.75
                                     target:self
                                   selector:@selector(captureStillImage)
                                   userInfo:nil repeats:NO];
    
}

/* captureStillImage: acquires the image from the camera, transforms it into a UIImage, and presents the move and scale view for user editing and final selection.
 */
-(void)captureStillImage {
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:[self cameraConnection:stillImageOutput] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){
        
        if (imageDataSampleBuffer) {
            
            
            //  UIImage* image = [self imageFromSampleBuffer:imageDataSampleBuffer];
            
            NSData* imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIDevice *device = [UIDevice currentDevice];
            
            UIImageOrientation theOrientation  = UIImageOrientationUp;
            
            switch (device.orientation) {
                    
                case UIDeviceOrientationPortrait:
                case UIDeviceOrientationFaceUp:
                    theOrientation = UIImageOrientationRight;
                    break;
                    
                case UIDeviceOrientationPortraitUpsideDown:
                case UIDeviceOrientationFaceDown:
                    theOrientation = UIImageOrientationLeft;
                    break;
                    
                case UIDeviceOrientationLandscapeLeft:
                    theOrientation = UIImageOrientationUp;
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                    theOrientation = UIImageOrientationDown;
                    break;
                    
                case UIDeviceOrientationUnknown:
                    NSLog(@"Device orientation has unknown value.");
                    break;
                    
            }
            
            UIImage *cameraImage = [UIImage imageWithData:imageData];
            
            cameraImage = [[UIImage alloc] initWithCGImage:cameraImage.CGImage scale:1.0 orientation:theOrientation];
            
            [session stopRunning];
            
            [self editImage:cameraImage];
            
        }
    }];
    
}

/* cameraConnection: returns a capture connection by walking through the collection of connections in the output object until it finds one of type AVMediaTypeVideo.
 */

-(AVCaptureConnection*)cameraConnection:(AVCaptureStillImageOutput*)imageOutput  {
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in imageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                
                videoConnection = connection;
                
                return videoConnection;
            }
        }
        
    }
    
    return nil;
    
}

/* getCameraDevice: walks through the list of capture devices and returns the camera device positioned on the back of the mobile computer.
 */
// #warning update to send the front or back device depending on what the user has selected.
-(AVCaptureDevice*)getCameraDevice {
    
    NSArray *devices = [AVCaptureDevice devices];
    
    AVCaptureDevice *device = nil;
    
    for (device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                break;
                
            }
        }
    }
    
    return device;
    
}

/* captureInput: creates device input object and adds it to the session.
 */
-(void)captureInput:(AVCaptureDevice*)device {
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input =[AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
    }
    
    [session addInput:input];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
