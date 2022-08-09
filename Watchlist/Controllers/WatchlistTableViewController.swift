//
//  WatchlistTableViewController.swift
//  Movie
//
//  Created by Денис on 08.08.2022.
//

import UIKit
import CoreData

class WatchlistTableViewController: UITableViewController {

    private var watchlist: [Movie] = []
    private var movies = [MovieModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFromCoreData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        movies.removeAll()
    }
    
    // Fetch
    private func fetchFromCoreData() {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        do {
            watchlist = try context.fetch(fetchRequest)
            
            for movie in watchlist {
                let movieModel = MovieModel(originalTitle: movie.originalTitle,
                                            overview: movie.overview,
                                            posterPath: movie.posterPath,
                                            releaseDate: movie.releaseDate,
                                            voteAverage: movie.voteAverage)
                self.movies.append(movieModel)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source

    // Register custom cell
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "MovieCell", bundle: nil)
        self.tableView.register(textFieldCell,forCellReuseIdentifier: "customCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell {
            cell.setup(model: movies[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    // Удаление записи
    private func deleteCell(_ tableView: UITableView, at indexPath: IndexPath) {
        movies.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        if let movies = try? context.fetch(fetchRequest) {
            let movie = movies[indexPath.row]
            context.delete(movie)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCell(tableView, at: indexPath)
        }
    }
    
}
