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

extension Collection {
    public var firstTwo: (Element, Element)? {
        guard self.count >= 2 else {
            return nil
        }
        return (self.first!, self.dropFirst().first!)
    }

    public var firstThree: (Element, Element, Element)? {
        guard self.count >= 3 else {
            return nil
        }
        return (self.first!, self.dropFirst().first!, self.dropFirst(2).first!)
    }
}
