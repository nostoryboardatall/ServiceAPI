//
//  ServiceProtocol.swift
//
//
//  Created by Alexander Pozakshin on 28.12.2023.
//

import Foundation

public protocol ServiceProtocol {
    var queue: DispatchQueue { get }
}

public extension ServiceProtocol {
    var queue: DispatchQueue { .main }
    
    func metha<T: Decodable & DecoderProvider>(_ source: Endpoint,
                                               gateway: Gateway<T>,
                                               queue: DispatchQueue,
                                               completion callback: @escaping (NetworkResult<APIError, T>) -> ())
    {
        gateway.methadata(source, queue: queue) { response in
            switch response {
            case let .fail(error):
                callback(.fail(error))
            case let .success(result):
                callback(.success(result))
            }
        }
    }

    func array<T: Decodable & DecoderProvider>(_ source: Endpoint,
                                               gateway: Gateway<T>,
                                               queue: DispatchQueue,
                                               completion callback: @escaping (NetworkResult<APIError, [T]>) -> ())
    {
        gateway.array(source, queue: queue) { response in
            switch response {
            case let .fail(error):
                callback(.fail(error))
            case let .success(result):
                callback(.success(result))
            }
        }
    }

    func data(_ source: Endpoint,
              gateway: Gateway<Data>,
              queue: DispatchQueue,
              completion callback: @escaping (NetworkResult<APIError, Data>) -> ())
    {
        gateway.raw(source, queue: queue) { response in
            switch response {
            case let .fail(error):
                callback(.fail(error))
            case let .success(result):
                callback(.success(result))
            }
        }
    }
}
