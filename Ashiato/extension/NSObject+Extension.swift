//
//  NSObject+Extension.swift
//  Ashiato
//
//  Created by Hajime Ito on 2021/08/28.
//

import Foundation

// MARK: クラス名の取得
public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        String(describing: self)
    }

    var className: String {
        Self.className
    }
}

extension NSObject: ClassNameProtocol {}
