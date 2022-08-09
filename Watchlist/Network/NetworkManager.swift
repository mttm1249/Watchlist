//
//  NetworkManager.swift
//  GZ
//
//  Created by Денис on 02.05.2022.
//

import Foundation

protocol Model: Codable { }

extension Array: Model where Element: Model { }

func asyncMain(action: @escaping () -> Void) {
    DispatchQueue.main.async(execute: action)
}

class NetworkManager {

    private static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMzZmOTkyZjgwOWRjZTFlMWM4ZDg4MTQ4MzkwMmYwZSIsInN1YiI6IjYyZTdiMTFhZmM1ZjA2MDA1OWMzYWY5MiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.CendcnY4dll7P7xRo0qp24Y8HNXl5PPHSCdwbqCfrcI"
        
    private static var session: URLSession?
    
    static let shared: NetworkManager = {
        let authValue = "Bearer \(apiKey)"
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [authValue: apiKey]
                config.httpAdditionalHeaders = ["Authorization": authValue]
        session = URLSession(configuration: config)
        return NetworkManager()
    }()
    
    func loadJson<T: Model>(urlString: String, path: String, params: [URLQueryItem], completion: @escaping (Result<T, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: urlString) else { return }
        urlComponents.path = path
        urlComponents.queryItems = params

        if let url = urlComponents.url {
            let urlSession = NetworkManager.session?.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    asyncMain { completion(.failure(error)) }
                }
                if let data = data {
                    do {
                        let value = try JSONDecoder().decode(T.self, from: data)
                        asyncMain { completion(.success(value)) }
                    } catch {
                        print(error)
                        asyncMain { completion(.failure(error)) }
                    }
                }
            }
            urlSession?.resume()
        }
    }
    
}

