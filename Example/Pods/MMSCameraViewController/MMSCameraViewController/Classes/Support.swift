//
//  Support.swift
//  Pods
//
//  Created by William Miller on 9/11/16.
//
//

import Foundation

internal func isDeviceOrientationPortrait() -> Bool {
    
    
    let orientation = UIDevice.current.orientation
    
    switch orientation {
    case .portrait, .portraitUpsideDown:
        return true
    default:
        return false
    }
}

internal func radians(degrees: Double) -> CGFloat {
    return CGFloat(degrees / 180 * Double.pi)
}
