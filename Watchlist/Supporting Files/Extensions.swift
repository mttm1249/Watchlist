//
//  Extensions.swift
//  Movie
//
//  Created by Денис on 04.08.2022.
//

import UIKit

// MARK: - Images activity indicator
extension UIImageView {
    func loadingIndicator() {
        var kf = self.kf
        kf.indicatorType = .activity
    }
}

// MARK: - Hide Keyboard Method
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - DateFormatter
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
       dateformat.locale = Locale(identifier: "en_us")

        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

// MARK: - scrollToTop method
extension SearchViewController {
    func scrollToTop() {        
        let topRow = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}

// MARK: - UserDefaults
extension UserDefaults {
    func appendToHistoryArray(by string: String) {
        let userDefaults = UserDefaults.standard
        var strings: [String] = userDefaults.stringArray(forKey: "history") ?? []
        strings.append(string)
        userDefaults.set(strings, forKey: "history")
    }
}
