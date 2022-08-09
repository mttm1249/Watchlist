//
//  TrendingTableViewController.swift
//  Movie
//
//  Created by Денис on 04.08.2022.
//

import UIKit
import Kingfisher

class TrendingTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var movies = [MovieModel]()
    private var page = 1
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        addLogo()
        registerTableViewCells()
        fetch()
    }
        
    private func addLogo() {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        tabBarController?.navigationItem.titleView = imageView
    }
    
    // Register custom cell
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "MovieCell", bundle: nil)
        self.tableView.register(textFieldCell,forCellReuseIdentifier: "customCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell {
            cell.setup(model: movies[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    // Portion data loading
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            
            page += 1
            CurrentURL.shared.page = String(page)
            fetch()
        }
    }
    
    //     MARK: Load data from JSON
    private func fetch() {
        NetworkManager.shared.loadJson(urlString: CurrentURL.shared.baseURL,
                                       path: CurrentURL.shared.trendingPath,
                                       params: CurrentURL.shared.params)
        {
            [weak self] (result: Result<Trending, Error>) in
            switch result {
            case .success(let data):
                
                let results = data.results
                for movie in results {
                    let movieModel = MovieModel(originalTitle: movie.originalTitle,
                                                overview: movie.overview,
                                                posterPath: movie.posterPath,
                                                releaseDate: movie.releaseDate,
                                                voteAverage: movie.voteAverage,
                                                id: movie.id)
                    self?.movies.append(movieModel)
                }
                if results.isEmpty {
                    CurrentURL.shared.page = "1"
                    self?.fetch()
                }
                self?.tableView.reloadData()
            case .failure(let error):
                self?.tableView.tableFooterView?.isHidden = true
                print("WE GOT ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    //     MARK: Pass data to DetailsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let movie = movies[indexPath.row]
            let detailsVC = segue.destination as! DetailsViewController
            detailsVC.currentMovie = movie
        }
    }
    
}

