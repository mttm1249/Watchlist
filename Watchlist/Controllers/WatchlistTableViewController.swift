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
                let movieModel = MovieModel(title: movie.title,
                                            overview: movie.overview,
                                            posterPath: movie.posterPath,
                                            releaseDate: movie.releaseDate,
                                            voteAverage: movie.voteAverage,
                                            viewed: movie.viewed)
                self.movies.append(movieModel)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
        
    // Save status of view
    private func saveStatus(_ tableView: UITableView, at indexPath: IndexPath) {
        let context = AppDelegate.getContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        if let movies = try? context.fetch(fetchRequest) {
            let movie = movies[indexPath.row]
            movie.viewed.toggle()
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Delete movie cell
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? MovieCell {
            cell.setup(model: movies[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedbackGenerator.impactOccurred()
        saveStatus(tableView, at: indexPath)
        movies.removeAll()
        fetchFromCoreData()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Remove") { (action, view, completion) in
            self.deleteCell(tableView, at: indexPath)
            tableView.reloadData()
        }
        action.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}


