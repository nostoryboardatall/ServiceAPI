//
//  CustomerErrorHandler.swift
//  APIKit
//
//  Created by Alexander Pozakshin on 03.07.2024.
//

import Foundation

public protocol CustomerError {
    associatedtype T: Codable & CoderProvider
    
    var instance: T { get }
    var localizedDescription: String { get }
    
    init(from data: Data) throws
}

public protocol CustomerErrorHandler {
    
    func handle(data: Data) -> (any CustomerError)?
    
}

public class CustomerErrorHandlerDefault: CustomerErrorHandler {
        
    public var classes: [(any CustomerError.Type)]
    
    public init(classes: [(any CustomerError.Type)]) {
        self.classes = classes
    }
    
    public func handle(data: Data) -> (any CustomerError)? {
        classes
            .compactMap({$0})
            .compactMap({ try? $0.init(from: data) })
            .first
    }

}
