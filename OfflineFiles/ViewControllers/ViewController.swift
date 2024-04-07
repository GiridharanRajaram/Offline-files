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
 
    let utilityFunctions = UtilityFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        folderCollectionView.delegate = self
        folderCollectionView.dataSource = self
        searchBar.delegate = self
        
        // Register XIB cell
        let nib = UINib(nibName: "FolderCollectionViewCell", bundle: nil)
        folderCollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        
        //DeleteAll for checking purpose
//    DatabaseHelper.instance.deleteAllData(forEntity: "Folders")
        
        // Check if there are folders in CoreData
          if let folders = DatabaseHelper.instance.fetchFolders(), !folders.isEmpty {
              // If there are folders, hide the label
              utilityFunctions.hideEmptyFolderLabel(fromView: self.view)
          } else {
              // If there are no folders, show the label
              utilityFunctions.showEmptyFolderLabel(inView: self.view, title: "Click + icon to add folders")
              
          }
        
        
        fetchAndUpdateCollectionView()
        
    }
    
 
    
    @IBAction func addFolderBtnAction(_ sender: Any) {
        
        createFolder()
    }
    
    
    
    @IBAction func filterBtnAction(_ sender: Any) {
        
        if searchBar.text?.isEmpty == false {
            searchBar.text = ""
            filteredFoldersName = foldersName
            folderCollectionView.reloadData()
        }
                  let alertController = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
                
                // Action for filtering by name
                let nameAction = UIAlertAction(title: "Name", style: .default) { [weak self] _ in
                    self?.toggleSortingByName()
                }
                updateActionState(nameAction, isSelected: isSortedByName)
                alertController.addAction(nameAction)
                
                // Action for filtering by date
                let dateAction = UIAlertAction(title: "Date (Ascending)", style: .default) { [weak self] _ in
                    self?.toggleSortingByDate()
                }
                updateActionState(dateAction, isSelected: isSortedByDate)
                alertController.addAction(dateAction)
                
                // Action for filtering by favorites
                let favoritesAction = UIAlertAction(title: "Favorites", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.isFilteredByFavorites.toggle()
                    self.fetchAndUpdateCollectionView()
                }
                updateActionState(favoritesAction, isSelected: isFilteredByFavorites)
                alertController.addAction(favoritesAction)
                
                // Cancel action
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                // Present the alert controller
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = filterBtn // Assuming filterBtn is your button triggering the action
                    popoverController.sourceRect = filterBtn.bounds
                }
                present(alertController, animated: true, completion: nil)
            }

            
        
    }

    func updateActionState(_ action: UIAlertAction, isSelected: Bool) {
        if isSelected {
            action.setValue(UIImage(systemName: "checkmark"), forKey: "image")
        } else {
            action.setValue(nil, forKey: "image")
        }
        
    }



