//
//  Gateway.swift
//
//
//  Created by Alexander Pozakshin on 27.12.2023.
//

import Foundation

public class Gateway<T: Decodable & DecoderProvider> {
    
    private let connector = Connector.shared
    
    public init() {}
    
    public func methadata(_ source: Endpoint,
                   queue: DispatchQueue,
                   completion callback: @escaping (NetworkResult<APIError, T>) -> ())
    {
        let resource = Resource<T>(request: source.builder(), as: .metha)
        connector.load(in: queue,
                       shouldLogRequest: source.shouldLogRequest,
                       shouldLogResponse: source.shouldLogResponse,
                       request: resource) { result in
            switch result {
            case let .fail(error):
                if source.shouldRetryOnAuthenticateError, error.isAuthorizeError {
                    self.connector.onAuntenticateErrorCallback?({ error in
                        callback(.fail(error))
                    }, { self.methadata(source, queue: queue, completion: callback) })
                } else {
                    callback(.fail(error))
                }
            case let .success(data):
                do {
                    let response = try resource.handlers.metha(data)
                    callback(.success(response))
                } catch let error {
                    if let error = error as? DecodingError {
                        callback(.fail(.encode(error)))
                    } else {
                        callback(.fail(.system(error)))
                    }
                }
            }
        }
    }
    
    public func array(_ source: Endpoint,
               queue: DispatchQueue,
               completion callback: @escaping (NetworkResult<APIError, [T]>) -> ())
    {
        let resource = Resource<T>(request: source.builder(), as: .array)
        connector.load(in: queue,
                       shouldLogRequest: source.shouldLogRequest,
                       shouldLogResponse: source.shouldLogResponse,
                       request: resource) { result in
            switch result {
            case let .fail(error):
                if source.shouldRetryOnAuthenticateError, error.isAuthorizeError {
                    self.connector.onAuntenticateErrorCallback?({ error in
                        callback(.fail(error))
                    }, { self.array(source, queue: queue, completion: callback) })
                } else {
                    callback(.fail(error))
                }
            case let .success(data):
                do {
                    let response = try resource.handlers.array(data)
                    callback(.success(response))
                } catch let error {
                    if let error = error as? DecodingError {
                        callback(.fail(.encode(error)))
                    } else {
                        callback(.fail(.system(error)))
                    }
                }
            }
        }
    }
    
    public func raw(_ source: Endpoint,
             queue: DispatchQueue,
             completion callback: @escaping (NetworkResult<APIError, Data>) -> ())
    {
        let resource = Resource<Data>(request: source.builder(), as: .raw)
        connector.load(in: queue,
                       shouldLogRequest: source.shouldLogRequest,
                       shouldLogResponse: source.shouldLogResponse,
                       request: resource) { result in
            switch result {
            case let .fail(error):
                if source.shouldRetryOnAuthenticateError, error.isAuthorizeError {
                    self.connector.onAuntenticateErrorCallback?({ error in
                        callback(.fail(error))
                    }, { self.raw(source, queue: queue, completion: callback) })
                } else {
                    callback(.fail(error))
                }
            case let .success(data):
                callback(.success(resource.handlers.raw(data)))
            }
        }
    }
}

private extension Gateway {
    func token(withKey key: String, from header: [AnyHashable : Any]) -> String? {
        var result: String? = nil
        header.keys.compactMap({ $0 as? String }).forEach({
            if $0.uppercased() == key.uppercased() {
                result = header[$0] as? String
            }
        })
        return result
    }
}
