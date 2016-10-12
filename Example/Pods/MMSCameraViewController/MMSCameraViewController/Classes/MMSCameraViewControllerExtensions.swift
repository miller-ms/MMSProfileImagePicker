//
//  MMSCameraViewControllerExtensions.swift
//  Pods
//
//  Created by William Miller on 9/18/16.
//
//
//  Copyright (c) 2016 William Miller <support@millermobilesoft.com>
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

import Foundation


extension MMSCameraViewController {
    
    func rotateDegrees(orientation: UIDeviceOrientation) -> Double {
        
        switch orientation {
            
        case .portrait:
            return 0.0
            
        case .portraitUpsideDown:
            return 180.0
            
        case .landscapeRight:
            return -90.0
            
        case .landscapeLeft:
            return 90.0
            
        default:
            return 0.0
            
        }
    }


    func deviceOrientation(_ inOrientation:UIDeviceOrientation) -> UIDeviceOrientation {
        
        let statusBarOrientation = UIDevice.current.orientation // UIApplication.sharedApplication().statusBarOrientation
        
        switch statusBarOrientation {
        case .portrait:
            return .portrait
            
        case .landscapeLeft:
            return .landscapeLeft
            
        case .landscapeRight:
            return .landscapeRight
            
        case .portraitUpsideDown:
            return .portraitUpsideDown
            
        case .faceUp, .faceDown:
            return inOrientation
            
        default:
            return .portrait
        }
        
    }

}
