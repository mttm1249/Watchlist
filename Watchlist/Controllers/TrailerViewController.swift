//
//  TrailerViewController.swift
//  Movie
//
//  Created by Денис on 07.08.2022.
//

import UIKit
import youtube_ios_player_helper

class TrailerViewController: UIViewController, YTPlayerViewDelegate {
    
    var currentMovieID: Int?
    private let shared = URLManager.shared
    private var currentMovieKey: String?
    private var currentTrailerTitle: String?
    
    @IBOutlet weak var blackoutView: UIView!
    @IBOutlet weak var trailerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trailerView.delegate = self
        blackoutView.backgroundColor = .black
        blackoutView.isHidden = false
        view.bringSubviewToFront(blackoutView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        navigationItem.title = currentTrailerTitle
    }
    
    //     MARK: Load data from JSON
    private func fetch() {
        NetworkManager.shared.loadJson(urlString: shared.baseURL,
                                       path: shared.getTrailerPath(from: currentMovieID!),
                                       params: shared.params)
        {
            [weak self] (result: Result<Trailer, Error>) in
            switch result {
            case .success(let data):
                let results = data.results
                for result in results {
                    self?.currentMovieKey = result.key
                    self?.currentTrailerTitle = result.name
                }
               
                if self?.currentMovieKey != nil {
                    self?.trailerView.load(withVideoId: (self?.currentMovieKey)!)
                    self?.navigationItem.title = self?.currentTrailerTitle
                } else {
                    self?.navigationItem.title = "Sorry, i can't find any trailers..."
                }

            case .failure(let error):
                print("WE GOT ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        blackoutView.isHidden = true
    }
    
}
