//
//  HistoryTextCell.swift
//  Watchlist
//
//  Created by Денис on 17.08.2022.
//

import UIKit

class HistoryTextCell: UITableViewCell {

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var searchTextLabel: UILabel!
    
    func setupIcon() {
        let color = #colorLiteral(red: 0.6093796492, green: 0.6073611975, blue: 0.6379041672, alpha: 1)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "clock")?.withTintColor(color)
        let imageString = NSAttributedString(attachment: imageAttachment)
        iconLabel.attributedText = imageString
    }
}
