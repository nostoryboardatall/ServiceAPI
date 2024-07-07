//
//  Cancellable.swift
//
//
//  Created by Alexander Pozakshin on 04.12.2023.
//

import Foundation

public protocol Cancellable {
    var isCancelled: Bool { get }
    func cancel()
}

public class CancellableWrapper: Cancellable {
    internal var innerCancellable: Cancellable = SimpleCancellable()

    public var isCancelled: Bool { innerCancellable.isCancelled }

    public func cancel() {
        innerCancellable.cancel()
    }
}

internal class SimpleCancellable: Cancellable {
    var isCancelled = false
    
    func cancel() {
        isCancelled = true
    }
}
