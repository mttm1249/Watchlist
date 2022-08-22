//
//  ViewController.swift
//  Movie
//
//  Created by Денис on 01.08.2022.
//

import UIKit
import Kingfisher

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {
    
    private let userDefaults = UserDefaults.standard
    private let searchController = UISearchController(searchResultsController: nil)
    private var movies = [MovieModel]()
    private var page = 1
    
    private var searchingRequestsArray: [String] = []
    private var searchingHistoryIsActive = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var upButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upButton.isEnabled = false
        searchBar.backgroundImage = UIImage()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        registerTableViewCells()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistory()
    }
    
    @IBAction func upButtonAction(_ sender: Any) {
        scrollToTop()
        upButton.isEnabled = false
    }
    
    private func loadHistory() {
        if let loadedStrings = UserDefaults.standard.stringArray(forKey: "history") {
            if loadedStrings.count >= 13 {
                userDefaults.removeObject(forKey: "history")
            }
            searchingRequestsArray = loadedStrings
        }
    }
    
    //     MARK: Load data from JSON
    private func fetch() {
        NetworkManager.shared.loadJson(urlString: URLManager.shared.baseURL,
                                       path: URLManager.shared.searchPath,
                                       params: URLManager.shared.params)
        {
            [weak self] (result: Result<Search, Error>) in
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
                print("WE GOT ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    // Register custom cell
    private func registerTableViewCells() {
        let searchTextCell = UINib(nibName: "HistoryTextCell", bundle: nil)
        self.tableView.register(searchTextCell,forCellReuseIdentifier: "historyTextCell")
        
        let movieCell = UINib(nibName: "MovieCell", bundle: nil)
        self.tableView.register(movieCell,forCellReuseIdentifier: "customCell")
    }
    
    //     MARK: UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchingHistoryIsActive {
            return searchingRequestsArray.count
        } else {
            return movies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchingHistoryIsActive {
            if let searchTextCell = tableView.dequeueReusableCell(withIdentifier: "historyTextCell", for: indexPath) as? HistoryTextCell {
                searchTextCell.searchTextLabel.text = searchingRequestsArray.reversed()[indexPath.row]
                searchTextCell.setupIcon()
                searchTextCell.backgroundColor = #colorLiteral(red: 0.1235060617, green: 0.2181218565, blue: 0.3138850033, alpha: 1)
                return searchTextCell
            }
        } else {
            if let movieCell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? MovieCell {
                movieCell.setup(model: movies[indexPath.row])
                movieCell.indicator.isHidden = true
                movieCell.backgroundColor = #colorLiteral(red: 0.009907525033, green: 0.1478210092, blue: 0.2553791106, alpha: 1)
                return movieCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchingHistoryIsActive {
            let searchRequestText = searchingRequestsArray.reversed()[indexPath.row]
            searchBar.text = searchRequestText
            searchBarSearchButtonClicked(searchBar)
            searchingHistoryIsActive = false
            tableView.reloadData()
        } else {
            performSegue(withIdentifier: "showDetails", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchingHistoryIsActive {
            return 40
        } else {
            return 181
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            search()
            fetch()
            searchingHistoryIsActive = false
            if let text = searchBar.text {
                userDefaults.appendToHistoryArray(by: text)
            }
        }
        searchBar.resignFirstResponder()
    }
    
    private func search() {
        tabBarController?.navigationItem.title = "\(searchBar.text!):"
        movies.removeAll()
        URLManager.shared.query = searchBar.text!
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        loadHistory()
        searchingHistoryIsActive.toggle()
        if searchingHistoryIsActive {
            tableView.reloadWithAnimation()
        } else {
            tableView.reloadData()
        }
    }
    
    // Portion data loading
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            if searchingHistoryIsActive == false {
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                self.upButton.isEnabled = true
                
                page += 1
                URLManager.shared.page = String(page)
                fetch()
            }
        }
    }
    
}
