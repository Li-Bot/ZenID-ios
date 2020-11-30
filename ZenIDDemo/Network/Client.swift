//
//  Client.swift
//  ZenIDDemo
//
//  Created by František Kratochvíl on 15.01.19.
//  Copyright © 2019 Trask, a.s. All rights reserved.
//

import UIKit

protocol ClientProtocol {
    func request<T>(_ endpoint: Endpoint<T>, completion:((T?, Error?) -> Void)?)
    func upload<T>(_ endpoint: UploadEndpoint<T>, completion:((T?, Error?) -> Void)?)
}

final class Client: ClientProtocol {
    private let baseURL = Credentials.shared.apiURL!
    private let session = URLSession(configuration: Manager.configuration)
        
    func request<T>(_ endpoint: Endpoint<T>, completion: ((T?, Error?) -> Void)?)  {
        guard let request = self.request(path: endpoint.path,
                                         method: endpoint.method,
                                         parameters: endpoint.parameters,
                                         headers: [:])
        else {
            #if DEBUG
            NSLog("Wrong request")
            #endif
            return
        }
        
        self.session.dataTask(with: request) { (data, response, error) in
            var result : T? = nil
            if let error = error {
                #if DEBUG
                if let respAsString = String(data:data ?? Data(), encoding: .utf8) {
                    NSLog("Response error %@: \ndata: %@", error.localizedDescription, respAsString)
                }
                #endif
            }
            else if let data = data {
                do {
                    result = try endpoint.decode(data)
                }
                catch {
                    #if DEBUG
                    NSLog("Decoding error: %@", error.localizedDescription)
                    #endif
                }
            }
            completion?(result, error)
        }.resume()
    }
    
    func upload<T>(_ endpoint: UploadEndpoint<T>, completion: ((T?, Error?) -> Void)?) {
        guard let request = self.request(path: endpoint.path,
                                         method: endpoint.method,
                                         parameters: endpoint.parameters,
                                         headers: ["Content-Type":"application/octet-stream"])
        
        else {
            #if DEBUG
            NSLog("Wrong request")
            #endif
            return
        }
        
        self.session.uploadTask(with: request, from: endpoint.data) { (data, response, error) in
            var result : T? = nil
            if let error = error {
                #if DEBUG
                if let respAsString = String(data:data ?? Data(), encoding: .utf8) {
                    NSLog("Response error %@: \ndata: %@", error.localizedDescription, respAsString)
                }
                #endif
            }
            if let data = data {
                do {
                    result = try endpoint.decode(data)
                }
                catch {
                    #if DEBUG
                    NSLog("Decoding error: %@", error.localizedDescription)
                    #endif
                }
            }
            completion?(result, error)
            }.resume()
    }
    
    private func url(path: Path) -> URL {
        return baseURL.appendingPathComponent(path)
    }
    
    private func request(path: String, method: Method, parameters: Parameters?, headers: Headers) -> URLRequest? {
        guard var components = URLComponents(url: self.url(path: path), resolvingAgainstBaseURL: false) else { return nil }
        
        components.queryItems = self.formatQueryItems(parameters: parameters)
        
        guard let url = components.url else { return nil}
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { (header) in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
    
    private func formatQueryItem(key: String, value: Any) -> [URLQueryItem] {
        if let array = value as? [Any] {
            return array.map { URLQueryItem(name: key, value: "\($0)") }
        }
        return [ URLQueryItem(name: key, value: "\(value)") ]
    }
    
    private func formatQueryItems(parameters: Parameters?) -> [URLQueryItem] {
        guard let allParams = parameters else { return [] }
        return allParams
            .flatMap { return formatQueryItem(key: $0.key, value: $0.value) }
            .compactMap { $0 }
    }
}

