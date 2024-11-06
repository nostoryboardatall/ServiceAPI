//
//  File.swift
//  
//
//  Created by Alexander Pozakshin on 06.11.2024.
//

import Foundation
#if canImport(Combine)
import Combine

public extension ServiceProtocol {
    @available(iOS 13.0, *)
    func metha<Output: Decodable & DecoderProvider>(_ source: Endpoint,
                                                    gateway: Gateway<Output>,
                                                    queue: DispatchQueue) -> AnyPublisher<Output, APIError> {
        Future { promise in
            metha(source, gateway: gateway, queue: queue) { response in
                switch response {
                case let .fail(error):
                    promise(.failure(error))
                case let .success(instance):
                    promise(.success(instance))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func array<Output: Decodable & DecoderProvider>(_ source: Endpoint,
                                                    gateway: Gateway<Output>,
                                                    queue: DispatchQueue) -> AnyPublisher<[Output], APIError> {
        Future { promise in
            array(source, gateway: gateway, queue: queue) { response in
                switch response {
                case let .fail(error):
                    promise(.failure(error))
                case let .success(instance):
                    promise(.success(instance))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func data(_ source: Endpoint, gateway: Gateway<Data>, queue: DispatchQueue) -> AnyPublisher<Data, APIError> {
        Future { promise in
            data(source, gateway: gateway, queue: queue) { response in
                switch response {
                case let .fail(error):
                    promise(.failure(error))
                case let .success(data):
                    promise(.success(data))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
