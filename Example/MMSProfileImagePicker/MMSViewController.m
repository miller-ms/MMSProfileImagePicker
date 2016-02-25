//
//  MMSViewController.m
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

#import "MMSViewController.h"

#import "MMSProfileImagePicker.h"

@interface MMSViewController () {

@private

MMSProfileImagePicker* profilePicker;

UIImage* cropImage;      // Croped image

UIImage* originalImage;  // Source of crop image.

}
@end

@implementation MMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mmsImagePickerControllerDidCancel:(MMSProfileImagePicker *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)mmsImagePickerController:(MMSProfileImagePicker *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"In didFinishPickingMediaWithInfo");
    
    cropImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.circleImageView.image = cropImage;
    
    self.squareImageView.image = cropImage;
    
    self.btnAdd.hidden = YES;
    
    self.circleImageView.hidden = NO;
    
    self.btnEdit.hidden = NO;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (IBAction)moveAndScale{
    
    profilePicker = [[MMSProfileImagePicker alloc] init];
    
    profilePicker.delegate = self;
    
    [profilePicker presentEditScreen:self withImage:originalImage];
    
}
- (IBAction)pickFromAlbum {
    
    
    profilePicker = [[MMSProfileImagePicker alloc] init];
    
    profilePicker.delegate = self;
    
    [profilePicker selectFromPhotoLibrary:self];
    
    
}

- (IBAction)pickFromCamera {
    
    profilePicker = [[MMSProfileImagePicker alloc] init];
    
    profilePicker.delegate = self;
        
    [profilePicker selectFromCamera:self];
        
}

- (IBAction)addImage:(UIButton *)sender {
    
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        [self pickFromCamera];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        [self pickFromAlbum];
        
        
    }]];
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
        
        //        [self dismissViewControllerAnimated:YES completion:nil];
        
        
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (IBAction)editImage:(UIButton *)sender {
    
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        [self pickFromCamera];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        [self pickFromAlbum];
        
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        [self moveAndScale];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        self.btnAdd.hidden = NO;
        
        self.circleImageView.hidden = YES;
        
        self.btnEdit.hidden = YES;
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
        
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}

@end
