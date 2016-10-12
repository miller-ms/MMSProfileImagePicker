//
//  MMSProfileImagePicker
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
@import AVFoundation;
@import CoreMedia;
@import ImageIO;

const CGFloat kOverlayInset = 10;

@implementation MMSProfileImagePicker

{
    
@private
    
    /**
     *  displays the circle mask
     */
    UIView* overlayView;
    
    /**
     *  holds the image to be moved and cropped
     */
    UIImageView* imageView;
    
    /**
     *  Holds the image for positioning and reasizing
     */
    UIScrollView* scrollView;
    
    /**
     *  Image passed to the edit screen.
     */
    UIImage*  imageToEdit;
    
    /**
     *  @"Move and Scale";
     */
    UILabel*  titleLabel;
    
    /**
     *  selects the image
     */
    UIButton* chooseButton;
    
    /**
     *  cancels cropping
     */
    UIButton* cancelButton;
    
    /**
     *  Rectangular area identifying the crop region
     */
    CGRect cropRect;
    
    /**
     *  This class proxy's for the UIImagePickerController
     */
    UIImagePickerController* imagePicker;
    
    /**
     *
     */
    MMSCameraViewController* camera;
    
    /**
     *  Session for captureing a still image
     */
    AVCaptureSession* session;
    
    /**
     *  holds the still image from the camera
     */
    AVCaptureStillImageOutput* stillImageOutput;
    
    /**
     *  Is displaying the photo picker
     */
    BOOL isDisplayFromPicker;

    /**
     *  to determine if the crop screen is displayed from the camera path
     */
    BOOL isPresentingCamera;
    
    /**
     *  to determine if the crop screen is displayed from the camera path
     */
    BOOL didChooseImage;

    /**
     *  true when the snap photo target has been replaced in the UIImagePickerController
     */
    BOOL isSnapPhotoTargetAdded;
    
    /**
     *  Set to true when camera has been initialized, so it only happens once.
     */
    BOOL isPreparingStill;
    
    /**
     *  The view controller that presented the MMSImagePickerController
     */
    UIViewController* presentingVC;
    
    
}

@synthesize minimumZoomScale = _minimumZoomScale, maximumZoomScale=_maximumZoomScale;
@synthesize backgroundColor=_backgroundColor;
@synthesize foregroundColor=_foregroundColor;
@synthesize overlayOpacity=_overlayOpacity;
//@synthesize image=_image;

-(instancetype) init {
    
    self = [super init];
    
    _minimumZoomScale = 1;
    _maximumZoomScale = 10;
    _backgroundColor = [UIColor blackColor];
    _foregroundColor = [UIColor whiteColor];
    _overlayOpacity = 0.6;
    isDisplayFromPicker = NO;
    session = nil;
    stillImageOutput = nil;
    isPresentingCamera = NO;
    isPreparingStill = NO;
    isSnapPhotoTargetAdded = NO;
    didChooseImage = NO;
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
/**
 *  Based on whether displaying the camera, photo library selection, or just editing an image, it dismisses the controllers displayed to support that in the proper sequence.
 *
 *  @param flag       Pass yes to animate the transition.
 *  @param completion The block to execute after the controller is dismissed.
 */
-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    

    if (isPresentingCamera) {
        
        [super dismissViewControllerAnimated:NO completion:completion];
        
        if (didChooseImage)
            [camera dismissViewControllerAnimated:NO completion:^{isPresentingCamera = NO; didChooseImage = NO;}];
        
        
    } else if (isDisplayFromPicker) {
        
        [super dismissViewControllerAnimated:NO completion:^{didChooseImage = NO;}];
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        isDisplayFromPicker = NO;
        
    } else {
        
        [super dismissViewControllerAnimated:flag completion:^{if (completion) completion(); didChooseImage = NO;}];

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

/**
 *  createSubViews: creates and positions the subviews to present functionality for moving and scaling an image having a circle overlay by default. It places the title, "Move and Scale" centered at the top of the screen.  A cancel button at the lower left corner and a choose button at the lower right corner.
 */
-(void) createSubViews {
    
    /* create the scrollView to fit within the physical screen size
     */
    CGRect screenRect = [UIScreen mainScreen].bounds;  // get the device physical screen dimensions
    
    scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    
    scrollView.backgroundColor = _backgroundColor;
    
    scrollView.delegate = self;
    
    scrollView.minimumZoomScale = _minimumZoomScale;    // content cannot shrink
    
    scrollView.maximumZoomScale = _maximumZoomScale;   // content can grow 10x original size
    
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

/** Add Title Label
 *  adds the "Move and Scale" title centered at the top of the parent view.
 *
 *  @param parentView the view to add the title to.
 *
 *  @return the label view added
 */
-(UILabel*)addTitleLabel:(UIView*)parentView {
    
    /*  define constants to create and position the title in the view.
     */
    const CGRect  kTitleFrame = {0.0f, 0.0f, 50.0f, 27.0f};
    const CGFloat kTopSpace = 25.0f;
    
    UILabel* label;
    
    label = [[UILabel alloc] initWithFrame:kTitleFrame];
    
    label.text = [self lString:@"Edit.title" comment:@"Localized edit tite"];
    
    label.textColor = _foregroundColor;
    
    [parentView addSubview:label];
    
    label.translatesAutoresizingMaskIntoConstraints = false;
    
    /* center the title in the view and position it a short distance from the top
     */
    [label.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor].active = YES;
    
    [label.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:kTopSpace].active = YES;
    
    return label;
}

/** Add Choose Button
 *  adds the button with the title "Choose" position at the bottom right corner of the parent view.
 *
 *  @param parentView The view to add the button to
 *  @param action     The method to call on the UIControlEventTouUpInside event
 *
 *  @return the button view added
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
        
        [button setTitle:[self lString:@"Button.choose.photoFromCamera" comment:@"Local use photo"] forState:UIControlStateNormal];
        
    } else {
        
        [button setTitle:[self lString:@"Button.choose.photoFromPicker" comment:@"Local use picker"]  forState:UIControlStateNormal];
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

/** Add Cancel Button
 *  adds the button with the title "Cancel" position at the bottom left corner of the parent view.
 *
 *  @param parentView The view to add the button to
 *  @param action     The method to call on the UIControlEventTouUpInside event
 *
 *  @return the button view added
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
        
        [button setTitle:[self lString:@"Button.cancel.photoFromCamera" comment:@"Local cancel photo"] forState:UIControlStateNormal];
        
    } else {
        
        [button setTitle:[self lString:@"Button.cancel.photoFromPicker" comment:@"Local cancel picker"] forState:UIControlStateNormal];
        
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


/** View For Zooming in ScrollView
 *  the imageView is the view for zooming the scroll view.
 *
 *  @param scrollView the scroll view with the request
 *
 *  @return the image view
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return imageView;
}

/**  Scroll View Did End Zooming
 *  Adjusts the scroll view's insets as the view enlarges.  As the scale enlarges the image, the insets shrink so that the edges do not move beyond the corresponding edge of the image mask when the it is scrolled.
 *
 *  @param sv    the scroll view
 *  @param view  the view that was zoomed
 *  @param scale the scale factor
 */
-(void)scrollViewDidEndZooming:(UIScrollView *)sv withView:(UIView *)view atScale:(CGFloat)scale {
    
    UIEdgeInsets insets;
    
    insets = [self insetsForImage:scrollView.contentSize withFrame:cropRect.size inView:[UIScreen mainScreen].bounds.size];
    
    sv.contentInset = insets;
}

/* centerRect:
 */

/** Center Rect
 *  retuns a rectangle's origin to position the inside rectangle centered within the enclosing one
 *
 *  @param insideRect  the inside rectangle
 *  @param outsideRect the rectangle enclosing the inside rectangle.
 *
 *  @return inside rectangle's origin to position it centered.
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

/** Center Square Rectangle in Rectangle
 *  creates a square with the shortest input dimensions less the insets, and positions the x and y coordinates such that it's center is the same center as would be the rectangle created from the input size and its origin at (0,0).
 *
 *  @param layerSize the size of the layer to create the centered rectangle in
 *  @param inset     the rectangle's insets
 *
 *  @return the centered rectangle
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

/** Create Overlay
 *  the overlay is the transparent view with the clear center to show how the image will appear when cropped. inBounds is the inside transparent crop region.  outBounds is the region that falls outside the inbound region and displays what's beneath it with dark transparency.
 *
 *  @param inBounds  the inside transparent crop rectangle
 *  @param outBounds the area outside inbounds.  In this solution it's always the screen dimensions.
 *
 *  @return the shape layer with a transparent circle and a darker region outside
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

/** insets for image with frame in view
 *  the goal of this routine is to calculate the insets so that the top and bottom of the image can align with the top and bottom of the frame when it is scrolled within the view.
 *
 *  @param imageSize height and width of the image
 *  @param frameSize size of the region where the image will be cropped to
 *  @param viewSize  size of the view where the image will display
 *
 *  @return <#return value description#>
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


#pragma mark - UIImagePickerControllerDelegate

/**  did finish picking media with info
 *  presents the move and scale screen with the selected image.
 *
 *  @param picker <#picker description#>
 *  @param info   <#info description#>
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    imageToEdit = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [imagePicker setNavigationBarHidden:YES];
    
    [imagePicker pushViewController:self animated:NO];
    
}

/** image picker controller did cancel
 *  this routine calls the equivalent this class's custome delegate method.
 *
 *  @param picker the image picker controller.
 */
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.delegate mmsImagePickerControllerDidCancel:self];
    
}


#pragma mark - action

/** choose
 *  called when the user is finished with moving and scaling the image to select it as final.  It crops the image and sends the information to the delegate.
 *
 *  @param sender the button view tapped
 */
-(IBAction)choose:(UIButton*)sender {
    
    UIImage* img;
    
    CGPoint cropOrigin;
    
    didChooseImage = YES;
    
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

/** cancel
 *  the user has decided to snap another photo if presenting the camera, to choose another image from the album if presenting the album, or to exit the move and scale when only using it to crop an image.
 *
 *  @param sender the button view tapped
 */
-(IBAction)cancel:(UIButton*)sender {
    
    if (isDisplayFromPicker) {
        
        [imagePicker popViewControllerAnimated:NO];
        
    } else if (isPresentingCamera) {
        
//        [imagePicker popViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    } else {
        
        [self.delegate mmsImagePickerControllerDidCancel:self];

    }
    
}
/* editImage: presents the move and scale view initialized with the input image.  This is only to be called from the presentCamera and presentPhotoPicker workflows after the user has captured an image or selected one.
 */
/**
 *
 *
 *  @param image <#image description#>
 */
-(void)editImage:(UIImage*)image {
    
    imageToEdit = image;
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
//    [imagePicker setNavigationBarHidden:YES];
    
//    [imagePicker pushViewController:self animated:NO];
    
    [camera presentViewController:self animated:YES completion:nil];
    
}

#pragma mark - Public Interface

/** present edit screen
 *  presents the move and scale window for a supplied image.  This use case is for when all that's required is to crop an image not to select one from the camera or photo album before cropping.
 *
 *  @param vc    view controller requesting presentation of the edit screen
 *  @param image the image to show in the edit screen
 */
-(void)presentEditScreen:(UIViewController* _Nonnull)vc withImage:(UIImage* _Nonnull)image{
    
    isDisplayFromPicker = isPresentingCamera = NO;
    
    imageToEdit = image;
    
    presentingVC = vc;
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [presentingVC presentViewController:self animated:YES completion:nil];

}

/**
 *  instantiates the UIImagePickerController object and configures it to present the photo library picker.
 *
 *  @param vc the view controller requesting presentation of the photo library selection.
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

/**
 *  instantiates the UIImagePickerController object and configures it to present the camera.
 *
 *  @param vc the view controller requesting presentation of the camera.
 */
- (void)selectFromCamera:(UIViewController* _Nonnull)vc {

    // *** new code here
    
    isPresentingCamera = YES;
    
    camera = [[MMSCameraViewController alloc] initWithNibName:nil bundle:nil];
    
    camera.delegate = self;
    
    presentingVC = vc;
    
    [presentingVC presentViewController:camera animated:NO completion:nil];
    
}

/**
 *  returns a localized string based on the key.
 *
 *  @param key - the identifier for the string.
 *  @param comment - the help text for the key.
 *
 *  @return - returns the localized string identified by the key.
 */
- (NSString*)lString:(NSString*) key comment:(NSString*)comment {
    
    return NSLocalizedStringFromTableInBundle(key, @"Localized", [NSBundle bundleForClass:[MMSProfileImagePicker class]], comment);
    
}


#pragma mark - Camera setup and capture
- (void)cameraDidCaptureStillImage:(UIImage *)image camera:(MMSCameraViewController *)cameraController {
    
    [self editImage:image];
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
