//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 6/22/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation


//Source: https://gist.github.com/gdavis/5745bb481af68791bbb8072b9b4a9711


/// A property wrapper that uses a serial `DispatchQueue` to access the underlying
/// value of the property, and `NSLock` to prevent reading while modifying the value.
///
/// This property wrapper supports mutating properties using coroutines
/// by implementing the `_modify` accessor, which allows the same memory
/// address to be modified serially when accessed from multiple threads.
/// See: https://forums.swift.org/t/modify-accessors/31872
@propertyWrapper public struct PopupThreadSafe<T> {

    private var _value: T
    private let lock = NSLock()
    private let queue: DispatchQueue

    public var wrappedValue: T {
        get {
            queue.sync { _value }
        }
        _modify {
            lock.lock()
            var tmp: T = _value

            defer {
                _value = tmp
                lock.unlock()
            }

            yield &tmp
        }
    }

    public init(wrappedValue: T, queue: DispatchQueue? = nil) {
        self._value = wrappedValue
        self.queue = queue ?? DispatchQueue(label: "PopupThreadSafe \(String(typeName: T.self))")
    }
}


// Helper extension to name the queue after the property wrapper's type.
public extension String {
    init(typeName thing: Any.Type) {
        let describingString = String(describing: thing)
        let name = describingString.components(separatedBy: ".").last ?? ""

        self.init(stringLiteral: name)
    }
}
