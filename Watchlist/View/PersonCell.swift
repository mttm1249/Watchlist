//
//  CustomCollectionViewCell.swift
//  Watchlist
//
//  Created by Денис on 09.08.2022.
//

import UIKit

class PersonCell: UICollectionViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var characterName: UILabel!
    
    func setup(model: PersonModel) {
        let defaultString = ""
        personName.text = model.name ?? defaultString
        characterName.text = model.character ?? defaultString
      
        // setup image
        let imageString = model.profilePath ?? defaultString
        let urlPath = "https://www.themoviedb.org/t/p/w276_and_h350_face"
        let url = URL(string: urlPath + imageString)
        personImage.loadingIndicator()
        personImage.kf.setImage(with: url)
    }
    
}
