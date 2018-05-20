//
//  Extensions.swift
//  Interpreter
//
//  Created by Alex Davis on 5/19/18.
//

import Foundation

extension Array where Element: CustomStringConvertible {
    public func joinedStrings(separator: String) -> String {
        return self.map({ $0.description }).joined(separator: separator)
    }
}
