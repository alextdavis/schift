//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

extension Array {
    /**
     Creates strings from the elements of the array, and then joins those strings with the given
     separator.
     */
    public func joinedStrings(separator: String) -> String {
        return self.map({ String(describing: $0) }).joined(separator: separator)
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
