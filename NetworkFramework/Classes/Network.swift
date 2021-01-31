//
//  Network.swift
//  NetworkFramework
//
//  Created by heetae.park on 2021/01/31.
//

import Foundation

public enum HTTPMethod: String {
    case GET     = "GET"
    case POST    = "POST"
    case PUT     = "PUT"
    case DELETE  = "DELETE"
}

public class Network<R: Codable> {

    private let session : URLSession = URLSession.shared
    private var _success: ((R?) -> Void)?
    private var _failure: ((Error) -> Void)?
    
    @discardableResult
    func request(url: String, method: HTTPMethod) -> Self {
        guard let url = URL(string: url) else { return self }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        send(req: request)
        return self
    }
    
    @discardableResult
    func success(cb: @escaping (R?) -> Void) -> Self {
        _success = cb
        return self
    }

    @discardableResult
    func failure(cb: @escaping (Error) -> Void) -> Self {
        _failure = cb
        return self
    }
    
    private func send(req: URLRequest) {
        session.dataTask(with: req) { [weak self] (data, response, error) in
            if let error = error {
                self?._failure?(error)
                return
            }

            do {
                let json = try JSONDecoder().decode(R.self, from: data!)
                self?._success?(json)
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }
        }.resume()
    }
}
