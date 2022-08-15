//
//  Details.swift
//  Watchlist
//
//  Created by Денис on 15.08.2022.
//


import Foundation

// MARK: - Details
struct Details: Model {
    let budget: Int
    let genres: [Genre]
    let originalLanguage: String
    let productionCompanies: [ProductionCompany]

    enum CodingKeys: String, CodingKey {
        case budget
        case genres
        case originalLanguage = "original_language"
        case productionCompanies = "production_companies"
    }
}

// MARK: - Genre
struct Genre: Codable {
    let name: String
}

// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let name: String
}


