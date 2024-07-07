//
//  Connector.swift
//
//
//  Created by Alexander Pozakshin on 26.12.2023.
//

import Foundation

public class Connector {
    public static var baseURLString: String?
    
    public static let shared: Connector = Connector()
    
    public var session = URLSession.shared
    
    public var onAuntenticateErrorCallback: ((@escaping ((APIError) -> Void), @escaping (() -> Void)) -> Void)?
    
    public var customerErroкHandler: CustomerErrorHandler = CustomerErrorHandlerDefault(classes: [])
    
    public var logger: URLLogger?
    
    private let cookieManager = CookieManager.shared
    
    private let networkQueue: DispatchQueue = .init(label: "ru.serviceapikit.network.queue",
                                                    qos: .utility,
                                                    attributes: .concurrent)
    
    static func setBaseURLString(_ value: String) {
        Connector.baseURLString = value
    }
    
    func load<T: Decodable & DecoderProvider>(in queue: DispatchQueue,
                                              shouldLogRequest: Bool,
                                              shouldLogResponse: Bool,
                                              request: Resource<T>,
                                              callback: @escaping (Response) -> Void) {
        setCookies()
        if shouldLogRequest, let jsonPretty = request.request.httpBody?.json()?.prettyPrinted() {
            logger?.log(type: .information, url: request.request.url, string: jsonPretty)
        }
        let task = session.dataTask(with: request.request) { [unowned self] data, response, error in
            if let error = error {
                if let urlError = error as? URLError {
                    if urlError.code == URLError.networkConnectionLost || urlError.code == URLError.notConnectedToInternet {
                        queue.async { callback(.fail(.status(.gatewayTimeout, Data()))) }
                    }
                } else {
                    queue.async { callback(.fail(.system(error))) }
                }
            } else {
                guard let data = data else {
                    queue.async { callback(.fail(.status(.noContent, Data()))) }
                    return
                }
                self.sink(in: queue,
                          response: response,
                          ofType: T.self,
                          data: data,
                          logging: shouldLogResponse) { response in
                                queue.async { callback(response) }
                }
            }
        }
        task.resume()
    }
}

private extension Connector {
    func setCookies() {
        guard let cookies = cookieManager.get else {
            return
        }
        guard let baseURLString = Connector.baseURLString else {
            return
        }
        let url = URL(string: baseURLString)
        session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: url)
    }

    func sink<T: Decodable & DecoderProvider>(in queue: DispatchQueue,
                                              response: URLResponse?,
                                              ofType: T.Type,
                                              data: Data,
                                              logging: Bool,
                                              completion callback: @escaping (Response) -> Void) {
        guard let response = response as? HTTPURLResponse else {
            publish(in: queue, result: .fail(.status(.gone, Data())), completion: callback)
            return
        }
        if logging, let jsonPretty = data.json()?.prettyPrinted() {
            logger?.log(type: .information, url: response.url, string: jsonPretty)
        }
        let status = HTTP.Status(rawValue: response.statusCode, kind: .unknown)
        guard status.isKnownStatus else {
            if let string = data.json()?.prettyPrinted(), !logging {
                logger?.log(type: .error, url: response.url, string: string)
            }
            publish(in: queue, result: .fail(.status(.undefined, data)), completion: callback)
            return
        }
        guard status != .unauthorized else {
            publish(in: queue, result: .fail(.status(.unauthorized, data)), completion: callback)
            return
        }
        if status.isSuccess == false {
            if let string = data.json()?.prettyPrinted(), !logging {
                logger?.log(type: .error, url: response.url, string: string)
            }
            
            if let error = customerErroкHandler.handle(data: data) {
                publish(in: queue, result: .fail(.customer(error)), completion: callback)
            } else {
                publish(in: queue, result: .fail(.status(status, data)), completion: callback)
            }
            return
        }
        cookieManager.save(response: response)
        if status.isSuccess {
            publish(in: queue, result: .success(data), completion: callback)
        } else {
            publish(in: queue, result: .fail(.status(status, data)), completion: callback)
        }
    }
    
    func publish(in queue: DispatchQueue, result: Response, completion callback: @escaping (Response) -> Void) {
        queue.async { callback(result) }
    }
}
