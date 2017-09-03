# MMSCameraViewController

[![CI Status](http://img.shields.io/travis/miller-ms/MMSCameraViewController.svg?style=flat)](https://travis-ci.org/miller-ms/MMSCameraViewController)
[![Version](https://img.shields.io/cocoapods/v/MMSCameraViewController.svg?style=flat)](http://cocoapods.org/pods/MMSCameraViewController)
[![License](https://img.shields.io/cocoapods/l/MMSCameraViewController.svg?style=flat)](http://cocoapods.org/pods/MMSCameraViewController)
[![Platform](https://img.shields.io/cocoapods/p/MMSCameraViewController.svg?style=flat)](http://cocoapods.org/pods/MMSCameraViewController)
[![CocoaPods](https://img.shields.io/cocoapods/dm/MMSCameraViewController.svg)](http://cocoapods.org/pods/MMSCameraViewController)

This class presents a camera for capturing still images and returning them to the presenting view controller through a callback to the delegate. Unlike many other camera controllers, this one does not provide the functionality for presenting a new view for accepting and cropping the captured image. It leaves that feature for the application to support providing more flexibility and customization by the application.

## Basic Usage
To run the example project, clone the repo, and run `pod install` from the Example directory first.

Import the class.

```Swift
import MMSCameraViewController
```

To present the camera, instantiate the controller object, assign the delegate, and present the view controller:

```swift

    @IBAction func openCamera(_ sender: AnyObject) {
        
        let camera = MMSCameraViewController(nibName: nil, bundle: nil)
        
        camera.delegate = self
        
        present(camera, animated: true, completion: nil)
        
    }
```

To acquire the image, implement the delegate:

```Swift
    func cameraDidCaptureStillImage(_ image: UIImage, camera:MMSCameraViewController) {
        
        imageView.image = image
        
        camera.dismiss(animated: true, completion: nil)

    }
```

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
MMSProfileImagePicker requires iOS 8.3 or later.

## Installation
MMSCameraViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MMSCameraViewController"
```

## Author
William Miller, support@millermobilesoft.com

## License
MMSCameraViewController is available under the MIT license. See the LICENSE file for more info.
