//
//  Array++.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

extension Array {
    @inlinable mutating func append(_ newElement: Element, if prerequisite: Bool) {
        if prerequisite { append(newElement) }
    }
    @inlinable mutating func replaceLast(_ newElement: Element, if prerequisite: Bool) {
        guard prerequisite else { return }

        switch isEmpty {
            case true: append(newElement)
            case false: self[count - 1] = newElement
        }
    }
    @inlinable mutating func removeLast() {
        if !isEmpty { removeLast(1) }
    }
    
    
    @inlinable mutating func replaceLastReturning(_ newElement: Element, if prerequisite: Bool) -> Element? {
        guard prerequisite else { return nil }
        var didReplace: Element? = nil
        switch isEmpty {
        case true:
            append(newElement)
        case false:
            didReplace = self.last
            self[count - 1] = newElement
        }
        return didReplace
    }
    
}
