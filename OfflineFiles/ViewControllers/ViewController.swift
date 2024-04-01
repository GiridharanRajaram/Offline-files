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
    
    
    var foldersName = [String]()
    var filteredFoldersName = [String]()
    var selectedFolder: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        folderCollectionView.delegate = self
        folderCollectionView.dataSource = self
        searchBar.delegate = self
        // Register XIB cell
            let nib = UINib(nibName: "FolderCollectionViewCell", bundle: nil)
            folderCollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
//        DatabaseHelper.instance.deleteAllData(forEntity: "Folders")
        fetchAndUpdateCollectionView()
        
     
    }

    @IBAction func addFolderBtnAction(_ sender: Any) {
        
        createFolder()
    }
    
    
    func createFolder() {
            let alertController = UIAlertController(title: "New Folder", message: "Do you want to create New Folder?", preferredStyle: .alert)
            
            alertController.addTextField{ (textField)  in
                textField.placeholder = "Enter a Folder Name"
            }
            
            let createAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                if let folderName = alertController.textFields?.first?.text {
                    DatabaseHelper.instance.saveFolder(name: folderName)
                    self.fetchAndUpdateCollectionView()
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(createAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
        func fetchAndUpdateCollectionView() {
            if let savedFolders = DatabaseHelper.instance.fecthFolders() {
                foldersName = savedFolders.compactMap{ $0.value(forKey: "name") as? String}
                filteredFoldersName = foldersName
                folderCollectionView.reloadData()
            }
        }
    }

    extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredFoldersName.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! FolderCollectionViewCell
            cell.folderImageView.image = UIImage(named: "folder_icon")
            cell.folderNameLbl.text = filteredFoldersName[indexPath.row]
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let selectedFolder = DatabaseHelper.instance.fecthFolders()?[indexPath.row] {
                 self.selectedFolder = selectedFolder
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilesViewController") as? FilesViewController {
                        vc.selectedFolder = selectedFolder
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
        }
     
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 120, height: 120)
        }
    }

    extension ViewController : UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredFoldersName = foldersName
            } else {
                filteredFoldersName = foldersName.filter { $0.lowercased().contains(searchText.lowercased()) }
            }
            folderCollectionView.reloadData()
        }
    }



