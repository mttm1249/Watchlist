//
//  DetailsViewController.swift
//  Movie
//
//  Created by Денис on 04.08.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var currentMovie = MovieModel()
        
    private let shared = URLManager.shared
    private var castPersons: [PersonModel] = []
    private var moviesInWatchlist: [Movie] = []
    private var savedMoviesID: [Int] = []
    private var equalResult: Bool?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCustomCell()
        fetchCastPersons()
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = currentMovie.originalTitle
        overviewText.text = currentMovie.overview
        loadImage()
        fetchFromCoreData()
        checkAlreadySavedMovie()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTrailer" {
            let trailerVC = segue.destination as! TrailerViewController
            trailerVC.currentMovieID = currentMovie.id
        }
        
        if segue.identifier == "showAll" {
            let allActorsCVC = segue.destination as! AllActorsCollectionViewController
            allActorsCVC.currentMovieID = currentMovie.id
        }
        
    }
    
    private func loadImage() {
        let imageString = currentMovie.posterPath
        let urlPath = "https://image.tmdb.org/t/p/w500"
        let url = URL(string: urlPath + imageString!)
        moviePoster.loadingIndicator()
        moviePoster.kf.setImage(with: url)
    }
    
    @IBAction func watchlistButtonAction(_ sender: Any) {
        if equalResult == false  {
            saveMovieToWatchlist(currentMovie)
            feedbackGenerator.impactOccurred()
            watchlistButton.setTitle("Saved", for: .normal)
            watchlistButton.layer.borderWidth = 2
            watchlistButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            equalResult = true
        }
    }
    
    // MARK: CoreData
    
    // Save
    private func saveMovieToWatchlist(_ movie: MovieModel) {
        let context = AppDelegate.getContext()
        let newEntry = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context)
        newEntry.setValue(movie.id, forKey: "id")
        newEntry.setValue(movie.originalTitle, forKey: "originalTitle")
        newEntry.setValue(movie.overview, forKey: "overview")
        newEntry.setValue(movie.posterPath, forKey: "posterPath")
        newEntry.setValue(movie.releaseDate, forKey: "releaseDate")
        newEntry.setValue(movie.voteAverage, forKey: "voteAverage")
        do {
            try context.save()
            print("Saved in CoreData")
        } catch {
            print("Error saving: \(error.localizedDescription)")
        }
    }
    
    //     MARK: Load data from JSON
    private func fetchCastPersons() {
        NetworkManager.shared.loadJson(urlString: shared.baseURL,
                                       path: shared.getCastPath(from: currentMovie.id!),
                                       params: shared.params)
        {
            [weak self] (result: Result<Cast, Error>) in
            switch result {
            case .success(let data):
                let cast = data.cast
                for person in cast {
                    let person = PersonModel(name: person.name,
                                             character: person.character,
                                             profilePath: person.profilePath)
                    
                    self?.castPersons.append(person)
                    self?.castCollectionView.reloadData()
                }
            case .failure(let error):
                print("WE GOT ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    // Fetch
    private func fetchFromCoreData() {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        do {
            moviesInWatchlist = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Check equal result
    private func checkAlreadySavedMovie() {
        for movie in moviesInWatchlist {
            let id = movie.id
            savedMoviesID.append(Int(id))
        }
        if savedMoviesID.contains(currentMovie.id!) {
            watchlistButton.setTitle("Already in watchlist", for: .normal)
            watchlistButton.layer.borderWidth = 2
            watchlistButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            equalResult = true
        } else {
            watchlistButton.setTitle("Add to watchlist", for: .normal)
            equalResult = false
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstTen = Array(castPersons.prefix(10))
        return firstTen.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personCell", for: indexPath) as? CustomCollectionViewCell {
            cell.setup(model: castPersons[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        return footerView
    }
        
    func registerCustomCell() {
        let customCell = UINib(nibName: "PersonCell", bundle: nil)
        self.castCollectionView.register(customCell,forCellWithReuseIdentifier: "personCell")
    }
    
}
