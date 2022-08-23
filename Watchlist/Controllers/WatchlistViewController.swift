//
//  WatchlistTableViewController.swift
//  Movie
//
//  Created by Денис on 08.08.2022.
//

import UIKit
import CoreData

class WatchlistViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource {
    
    private var watchlist: [Movie] = []
    private var movies = [MovieModel]()
    private var sortedMovies: [MovieModel] = []
    private var sortingActive = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray],
                                                for: .selected)
        registerTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFromCoreData(withStatus: 0)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        movies.removeAll()
    }
    
    private func sorting() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentedControl.selectedSegmentTintColor = #colorLiteral(red: 0.5311042666, green: 0.7751688361, blue: 0.6109445095, alpha: 1)
            sortingActive = false
            movies.removeAll()
            fetchFromCoreData(withStatus: 0)
        case 1:
            segmentedControl.selectedSegmentTintColor = #colorLiteral(red: 0.3547364473, green: 0.7621669769, blue: 0.7401419282, alpha: 1)
            sortingActive = true
            sortedMovies.removeAll()
            fetchFromCoreData(withStatus: 1)
        case 2:
            segmentedControl.selectedSegmentTintColor = #colorLiteral(red: 0.007972300053, green: 0.7087039948, blue: 0.8930794001, alpha: 1)
            sortingActive = true
            sortedMovies.removeAll()
            fetchFromCoreData(withStatus: 2)
        default:
            break
        }
        tableView.reloadData()
    }
    
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        sorting()
    }
    
    // Fetch
    private func fetchFromCoreData(withStatus: Int) {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        do {
            watchlist = try context.fetch(fetchRequest)
            
            for movie in watchlist {
                let movieModel = MovieModel(title: movie.title,
                                            overview: movie.overview,
                                            posterPath: movie.posterPath,
                                            releaseDate: movie.releaseDate,
                                            voteAverage: movie.voteAverage,
                                            id: Int(movie.id),
                                            viewed: movie.viewed)
                
                switch withStatus {
                case 0:
                    self.movies.append(movieModel)
                case 1:
                    if movieModel.viewed == true {
                        self.sortedMovies.append(movieModel)
                    }
                case 2:
                    if movieModel.viewed == false {
                        self.sortedMovies.append(movieModel)
                    }
                default:
                    break
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Save status
    private func saveStatus(selectedMovie: MovieModel) {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        if let movies = try? context.fetch(fetchRequest) {
            for movie in movies {
                if movie.id == selectedMovie.id! {
                    movie.viewed.toggle()
                }
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Delete movie cell
    private func deleteCell(selectedMovie: MovieModel) {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        if let movies = try? context.fetch(fetchRequest) {
            for movie in movies {
                if movie.id == selectedMovie.id! {
                    context.delete(movie)
                }
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    // Register custom cell
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "MovieCell", bundle: nil)
        self.tableView.register(textFieldCell,forCellReuseIdentifier: "movieCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortingActive {
            return sortedMovies.count
        } else {
            return movies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? MovieCell {
            if sortingActive {
                cell.setup(model: sortedMovies[indexPath.row])
            } else {
                cell.setup(model: movies[indexPath.row])
            }
            cell.backgroundColor = #colorLiteral(red: 0.07019228488, green: 0.1790097058, blue: 0.2869570553, alpha: 1)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedbackGenerator.impactOccurred()
        if sortingActive {
            let selectedMovie = sortedMovies[indexPath.row]
            saveStatus(selectedMovie: selectedMovie)
            sortedMovies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        } else {
            let selectedMovie = movies[indexPath.row]
            saveStatus(selectedMovie: selectedMovie)
            movies.removeAll()
            fetchFromCoreData(withStatus: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Remove") { (action, view, completion) in
            if self.sortingActive {
                let selectedMovie = self.sortedMovies[indexPath.row]
                self.deleteCell(selectedMovie: selectedMovie)
                self.sortedMovies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            } else {
                let selectedMovie = self.movies[indexPath.row]
                self.deleteCell(selectedMovie: selectedMovie)
                self.movies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
        action.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 181
    }
    
}


