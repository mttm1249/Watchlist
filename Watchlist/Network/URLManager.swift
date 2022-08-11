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
    var searchPath = "/3/search/movie"
    var trendingPath = "/3/trending/movie/week"
    
    var params: [URLQueryItem] {
        [
            .init(name: "query", value: query),
            .init(name: "page", value: page)
            ]
    }
    
    // Parametres values
    var query = ""
    var page = ""
    var movieID = ""
    
    func getTrailerPath(from movieID: Int) -> String {
       let path = "/3/movie/\(movieID))/videos"
       return path
   }
    
    func getCastPath(from movieID: Int) -> String {
        let path = "/3/movie/\(movieID))/credits"
        return path
    }
    
    static let shared = URLManager()
    private init() {}
}

