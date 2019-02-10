//
//  Internationalization.swift
//  Pods
//
//  Created by William Miller on 9/5/16.
//
// swiftlint:disable line_length

import Foundation

class International {

    public static let interface = International()

    func LString(_ key: String, comment: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: Bundle(for: International.self), value: "", comment: comment)
    }

}
