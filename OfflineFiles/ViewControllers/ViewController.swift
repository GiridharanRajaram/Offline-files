//
//  ViewController.swift
//  OfflineFiles
//
//  Created by Giridharan on 30/03/24.
//

import UIKit
import CoreData

class ViewController: UIViewController{
   
    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterBtn: UIButton!
    
    var foldersName = [String]()
    var filteredFoldersName = [String]()
    var selectedFolder: NSManagedObject?
    var isSortedByName = false
    var isSortedByDate = false
    var isFilteredByFavorites = false
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        folderCollectionView.delegate = self
        folderCollectionView.dataSource = self
        searchBar.delegate = self
        
        // Register XIB cell
        let nib = UINib(nibName: "FolderCollectionViewCell", bundle: nil)
        folderCollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
//                DatabaseHelper.instance.deleteAllData(forEntity: "Folders")
        fetchAndUpdateCollectionView()
        
    }
    
    
    
    @IBAction func addFolderBtnAction(_ sender: Any) {
        
        createFolder()
    }
    
    
    
    @IBAction func filterBtnAction(_ sender: Any) {
        
        let action1 = UIAction(title: "Name", image: UIImage(systemName:  "chevron.up"), handler: { [weak self] _ in
            self?.toggleSortingByName()
        })
        let action2 = UIAction(title: "Date (Ascending)", image: UIImage(systemName: "calendar"), handler: {[weak self] _ in
            self?.toggleSortingByDate()
        })
        let favorites = UIAction(title: "Favorites", image: UIImage(systemName: "star"), identifier: nil, discoverabilityTitle: nil, state: .off) { [weak self] (_) in
            guard let self = self else { return }
            
            self.isFilteredByFavorites.toggle()
            self.fetchAndUpdateCollectionView()
        }
        
        
        let menu = UIMenu(title: "", children: [action1, action2, favorites])
        filterBtn.menu = menu
        filterBtn.showsMenuAsPrimaryAction = true
        
    }
    
}








