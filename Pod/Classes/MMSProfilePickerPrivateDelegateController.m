//
//  MMSDelegateController.m
//  MMSImagePickerController
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

#import "MMSProfilePickerPrivateDelegateController.h"
#import "MMSProfileImagePicker.h"


@interface MMSProfilePickerPrivateDelegateController ()

{
@private
    
    /**
     *  Holds the reference to the profile picker so that it can call it when the navigation controller calls are made.
     */
    MMSProfileImagePicker *mmsPicker;
        
}

@end

@implementation MMSProfilePickerPrivateDelegateController
/** init with picker
 *  When the private delegat is created it is initialized with the profile picker instance.
 *
 *  @param presentingPicker The profile picker instance
 *
 *  @return A reference to the private delegate controller
 */
-(instancetype)initWithPicker:(MMSProfileImagePicker *)presentingPicker {
    
    mmsPicker = presentingPicker;
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** did show view controller
 *  Passes the invocation directly to the image picker.
 *
 *  @param navigationController The navigation controller
 *  @param viewController       The view controller being pushed on the stack
 *  @param animated             true if the view controller shows animated.
 */
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
        
    [mmsPicker navigationController:navigationController didShowViewController:viewController animated:animated];
    
    return;
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
