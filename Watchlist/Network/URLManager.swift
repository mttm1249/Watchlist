//
//  CurrentURLManager.swift
//  Movie
//
//  Created by Денис on 03.05.2022.
//

import Foundation

class URLManager {
    
    // URL
    var baseURL = "https://api.themoviedb.org"
   
    // Path
    var searchPath = "/3/search/movie"
    var trendingPath = "/3/trending/movie/week"
    
    // Parametres
    var params: [URLQueryItem] {
        [
            .init(name: "query", value: query),
            .init(name: "page", value: page)
            ]
    }
    
    // Parametres values
    var query = ""
    var page = ""
    
    func getTrailerPath(from movieID: Int) -> String {
       let path = "/3/movie/\(movieID))/videos"
       return path
   }
    
    func getCastPath(from movieID: Int) -> String {
        let path = "/3/movie/\(movieID))/credits"
        return path
    }
    
    func getDetailsPath(from movieID: Int) -> String {
        let path = "/3/movie/\(movieID)"
        return path
    }
    
    static let shared = URLManager()
    private init() {}
}

