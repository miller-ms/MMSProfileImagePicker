# MMSProfileImagePicker

[![CI Status](http://img.shields.io/travis/miller-ms/MMSProfileImagePicker.svg?style=flat)](https://travis-ci.org/miller-ms/MMSProfileImagePicker)
[![Version](https://img.shields.io/cocoapods/v/MMSProfileImagePicker.svg?style=flat)](http://cocoapods.org/pods/MMSProfileImagePicker)
[![License](https://img.shields.io/cocoapods/l/MMSProfileImagePicker.svg?style=flat)](http://cocoapods.org/pods/MMSProfileImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/MMSProfileImagePicker.svg?style=flat)](http://cocoapods.org/pods/MMSProfileImagePicker)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=miller-ms/mmsprofileimagepicker)](http://clayallsopp.github.io/readme-score?url=miller-ms/mmsprofileimagepicker)

## Overview
This class provides the capabilities for selecting an image from the photo library or camera, or submitting one for editing in a circular mask.  The selected and edited image would typically be used for a profile displayed in a circle. With this class an application can provide identical profile selection features found in the contacts app.

<p align="center">
<img src="screenshot.gif" alt="Example">
</p>

## Basic Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Import the class header.

```objc
#import "MMSProfileImagePicker.h"
```

Create a the profile picker object.  The application's view controller implements the MMSProfileImagePickerDelegate interface.  The interface's method is where profile picker passes the selected and edited image. Before calling one of the profile picker's methods, the application sets its delegate property.

```objc
- (IBAction)pickFromCamera {

    profilePicker = [[MMSProfileImagePicker alloc] init];

    profilePicker.delegate = self;

    [profilePicker selectFromCamera:self];

}
```

There are three public methods for selecting and editing a profile image.  For editing an existing image call...

```objc
-(void)presentEditScreen:(UIViewController* _Nonnull)vc withImage:(UIImage* _Nonnull)image;
```

For editing an image selected from the photo library call...
```objc
-(void)selectFromPhotoLibrary:(UIViewController* _Nonnull)vc;
```

For editing an image selected from the camera call...

```objc
-(void)selectFromCamera:(UIViewController* _Nonnull)vc;
```
To receive the selected and edited image implement the delegate method...

```objc
-(void)mmsImagePickerController:(MMSProfileImagePicker* _Nonnull)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*_Nonnull)info;
```
The dictionary parameter supports all the editing information keys defined in [editing information keys found in the iOS developer documentation](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImagePickerControllerDelegate_Protocol/#//apple_ref/doc/constant_group/Editing_Information_Keys).

If the user cancels the selection, the application receives notificaton on the delegate method...

```objc
-(void)mmsImagePickerControllerDidCancel:(MMSProfileImagePicker * _Nonnull)picker;
```

## Requirements

MMSProfileImagePicker requires iOS 7.2 or later.

## Installation

MMSProfileImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MMSProfileImagePicker"
```

## Article

An article describing the implementation of the class:  [A Class for Selecting a Profile Image](http://www.codeproject.com/Articles/1080877/A-Class-for-Selecting-a-Profile-Image).

A related article describing the cropping category:  [A View Class for Cropping Images](http://www.codeproject.com/Articles/1066191/A-View-Class-for-Cropping-Images).

## Author

William Miller, support@millermobilesoft.com

## License

This project is is available under the MIT license. See the LICENSE file for more info. Add attibution by linking to the [project page](https://github.com/miller-ms/MMSProfileImagePicker) is appreciated.
