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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? MovieCell {
            cell.setup(model: movies[indexPath.row])
            cell.indicator.isHidden = true
            cell.backgroundColor = #colorLiteral(red: 0.009907525033, green: 0.1478210092, blue: 0.2553791106, alpha: 1)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 181
    }
        
    //     MARK: Load data from JSON
    private func fetch() {
        URLManager.shared.page = "1"
        NetworkManager.shared.loadJson(urlString: URLManager.shared.baseURL,
                                       path: URLManager.shared.trendingPath,
                                       params: URLManager.shared.params)
        {
            [weak self] (result: Result<Trending, Error>) in
            switch result {
            case .success(let data):
                let results = data.results
                for movie in results {
                    let movieModel = MovieModel(title: movie.title,
                                                overview: movie.overview,
                                                posterPath: movie.posterPath,
                                                releaseDate: movie.releaseDate,
                                                voteAverage: movie.voteAverage,
                                                id: movie.id)
                    self?.movies.append(movieModel)
                }
                if results.isEmpty {
                    URLManager.shared.page = "1"
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

