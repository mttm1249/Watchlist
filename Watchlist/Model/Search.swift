//
//  Search.swift
//  Movie
//
//  Created by Денис on 05.08.2022.
//


import Foundation

// MARK: - Search
struct Search: Model {
    let page: Int
    let results: [Results]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Result
struct Results: Codable {
    let originalTitle, overview: String
    let posterPath: String?
    let id: Int
    let releaseDate: String?
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {

        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case id
    }
}

