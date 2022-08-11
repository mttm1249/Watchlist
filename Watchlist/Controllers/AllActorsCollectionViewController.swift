//
//  AllActorsCollectionViewController.swift
//  Watchlist
//
//  Created by Денис on 11.08.2022.
//

import UIKit

class AllActorsCollectionViewController: UIViewController, UISheetPresentationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var currentMovieID: Int?
    
    private let shared = URLManager.shared
    private var castPersons: [PersonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        sheetPresentationController.delegate = self
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.selectedDetentIdentifier = .medium
        sheetPresentationController.detents = [.medium(), .large()]
        registerCustomCell()
        fetchCastPersons()
    }
    
    func registerCustomCell() {
        let customCell = UINib(nibName: "PersonCell", bundle: nil)
        self.collectionView.register(customCell,forCellWithReuseIdentifier: "personCell")
    }
    
    //     MARK: Load data from JSON
    private func fetchCastPersons() {
        NetworkManager.shared.loadJson(urlString: shared.baseURL,
                                       path: shared.getCastPath(from: currentMovieID!),
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
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("WE GOT ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return castPersons.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personCell", for: indexPath) as? CustomCollectionViewCell {
            cell.setup(model: castPersons[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
 
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
