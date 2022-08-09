//
//  CustomTableViewCell.swift
//  Movie
//
//  Created by Денис on 03.08.2022.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieVoteLabel: UILabel!
    
    func setup(model: MovieModel) {
        let defaultString = ""

        movieNameLabel.text = model.originalTitle ?? defaultString
        overviewLabel.text = "Overview: \(model.overview ?? defaultString)"
        
        if model.voteAverage != nil {
            movieVoteLabel.text = "TMDB Rating: \(model.voteAverage!)"
        }
        
        let dateString = model.releaseDate
                            if dateString != "" {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                let date = dateFormatter.date(from:dateString!)
                                let formattedDate = date!.getFormattedDate(format: "MMM d, yyyy")
                                releaseDateLabel.text = "\(formattedDate)"
                            } else {
                                releaseDateLabel.text = ""
                            }
        // setup image
        let imageString = model.posterPath ?? defaultString
        let urlPath = "https://image.tmdb.org/t/p/w500"
        let url = URL(string: urlPath + imageString)
        movieImage.loadingIndicator()
        movieImage.kf.setImage(with: url)
    }
        
}
