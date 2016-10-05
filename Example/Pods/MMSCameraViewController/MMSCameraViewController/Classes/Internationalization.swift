//
//  Internationalization.swift
//  Pods
//
//  Created by William Miller on 9/5/16.
//
//

import Foundation

class International  {
    
    open static let interface = International()
    
    func LString(_ key: String, comment:String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: Bundle(for: International.self), value: "", comment: comment)
    }
    
    
}
