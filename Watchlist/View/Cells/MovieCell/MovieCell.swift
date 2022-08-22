//
//  CustomTableViewCell.swift
//  Movie
//
//  Created by Денис on 03.08.2022.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieVoteLabel: UILabel!
    @IBOutlet weak var indicator: UIImageView!
    
    func setup(model: MovieModel) {
        let defaultString = ""
        let eyeImage = (UIImage(systemName: "eye"))
        let emptyMovieImage = (UIImage(systemName: "multiply"))
        
        if model.viewed == true {
            indicator.isHidden = false
            indicator.image = eyeImage
        } else {
            indicator.isHidden = true
        }
        
        movieNameLabel.text = model.title ?? defaultString
        overviewLabel.text = model.overview ?? defaultString
        
        if model.voteAverage != nil {
            movieVoteLabel.text = "Rating: \(model.voteAverage!)"
        }
        
        let dateString = model.releaseDate
        if dateString != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from:dateString!)
            let formattedDate = date?.getFormattedDate(format: "MMM d, yyyy")
            releaseDateLabel.text = "\(formattedDate ?? defaultString)"
        } else {
            releaseDateLabel.text = "Release date unknown"
        }
        // setup image
        let imageString = model.posterPath
        if imageString != nil {
            let urlPath = "https://image.tmdb.org/t/p/w500"
            let url = URL(string: urlPath + imageString!)
            movieImage.loadingIndicator()
            movieImage.kf.setImage(with: url)
        } else {
            movieImage.image = emptyMovieImage
            movieImage.contentMode = .scaleAspectFit
        }
    }
    
}
