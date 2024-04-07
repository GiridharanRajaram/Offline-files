//
//  ViewControllerExtensions.swift
//  OfflineFiles
//
//  Created by Giridharan on 06/04/24.
//

import Foundation
import UIKit





extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ColorOptionsDelegate {
  

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFoldersName.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! FolderCollectionViewCell
        cell.folderImageView.image = UIImage(named: "folder_icon")
        cell.folderNameLbl.text = filteredFoldersName[indexPath.row]
        
        if let folder = DatabaseHelper.instance.fetchFolders()?[indexPath.row],
           let colorData = folder.value(forKey: "color") as? Data,
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            cell.tagColorView.backgroundColor = color
        } else {
            cell.tagColorView.backgroundColor = .clear
        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedFolder = DatabaseHelper.instance.fetchFolders()?[indexPath.row] {
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
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }

    func configureContextMenu(index: Int) -> UIContextMenuConfiguration {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) {[weak self] (_) in
                self?.editFolderName(at: index)
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) {  [weak self]  (_) in
                
                guard let self = self else { return }
        
                let folderNameToDelete = self.filteredFoldersName[index]
                DatabaseHelper.instance.deleteFolder(name: folderNameToDelete)
                self.filteredFoldersName.remove(at: index)
                if self.filteredFoldersName.isEmpty {
                    utilityFunctions.showEmptyFolderLabel(inView: self.view, title: "Click + icon to add folders")
                }
                self.folderCollectionView.reloadData()
               
            }
            let favouritesTitle = self.isFavourite(at: index) ? "Unfavorite" : "Favorite"
            let favouritesImage = UIImage(systemName: self.isFavourite(at: index) ? "star.slash" : "star")
                 let favourites = UIAction(title: favouritesTitle, image: favouritesImage, identifier: nil, discoverabilityTitle: nil, state: .off) { [weak self] (_) in
                     self?.toggleFavourite(at: index)
                 }
            
            let tag = UIAction(title: "Tags", image: UIImage(systemName: "tag"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let destVC = storyboard.instantiateViewController(withIdentifier: "ColorOptionsViewController") as! ColorOptionsViewController
                destVC.colorIndex = index
                destVC.delegate = self
               self.present(destVC, animated: true, completion: nil)
            }
            
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete, favourites,tag])
            
        }
        return context
    }

    
    func didSelectColor() {
    
      folderCollectionView.reloadData()
        
    }

}



extension ViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
          filteredFoldersName = foldersName
        } else {
            filteredFoldersName = filteredFoldersName.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        folderCollectionView.reloadData()
    }
    
}


extension ViewController {
    
    
    func toggleFavourite(at index: Int) {
        if let folders = DatabaseHelper.instance.fetchFolders(), index < folders.count {
            let folder = folders[index]
            
            if let currentIsFavorite = folder.value(forKey: "isFavorite") as? Bool {
                folder.setValue(!currentIsFavorite, forKey: "isFavorite")
            } else {
                folder.setValue(true, forKey: "isFavorite")
            }
            
            DatabaseHelper.instance.saveContext()
            if isFilteredByFavorites {
                    fetchAndUpdateCollectionView()
                }
        } else {
            print("Error: Invalid index or unable to fetch folders.")
        }
    }
    
    
    func isFavourite(at index: Int) -> Bool {
        if let folders = DatabaseHelper.instance.fetchFolders(), index < folders.count {
            let folder = folders[index]
            if let isFavorite = folder.value(forKey: "isFavorite") as? Bool {
                return isFavorite
            } else {
                return false
            }
        } else {
            
            return false
        }
    }
    
    
    
    func editFolderName(at index: Int) {
        guard let folders = DatabaseHelper.instance.fetchFolders(), index < folders.count else { return }
        
        let folder = folders[index]
        let oldName = folder.value(forKey: "name") as? String
        
        let alertController = UIAlertController(title: "Edit Folder Name", message: "Enter new folder name", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New Folder Name"
            textField.text = oldName
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (_) in
            guard let newName = alertController.textFields?.first?.text else { return }
            
            if self?.isFolderNameExists(folderName: newName) ?? false {
                self?.showAlert(message: "Folder with this name already exists.")
            } else {
                folder.setValue(newName, forKey: "name")
                DatabaseHelper.instance.saveContext()
                if let indexInFilteredArray = self?.filteredFoldersName.firstIndex(of: oldName ?? "") {
                    self?.filteredFoldersName[indexInFilteredArray] = newName
                    self?.folderCollectionView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func toggleSortingByName() {
        isSortedByName.toggle()
        if isSortedByName {
            filteredFoldersName.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            folderCollectionView.reloadData()
        } else {
            filteredFoldersName = foldersName
            folderCollectionView.reloadData()
        }
    }
    
    func sortFoldersByDate() {
        if let sortedFolders = DatabaseHelper.instance.fetchFoldersSortedByDate() {
            filteredFoldersName = sortedFolders.compactMap { $0.value(forKey: "name") as? String }
            folderCollectionView.reloadData()
        }
    }
    
    func toggleSortingByDate() {
        isSortedByDate.toggle()
        if isSortedByDate {
            sortFoldersByDate()
        } else {
            filteredFoldersName = foldersName
            folderCollectionView.reloadData()
        }
    }

    func createFolder() {
        let alertController = UIAlertController(title: "New Folder", message: "Do you want to create New Folder?", preferredStyle: .alert)
        
        alertController.addTextField{ (textField)  in
            textField.placeholder = "Enter a Folder Name"
        }
        
        let createAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            if let folderName = alertController.textFields?.first?.text {
                if !self.isFolderNameExists(folderName: folderName) {
                    DatabaseHelper.instance.saveFolder(name: folderName)
                    self.utilityFunctions.hideEmptyFolderLabel(fromView: self.view)
                    self.fetchAndUpdateCollectionView()
                } else {
                    self.showAlert(message: "Folder with this name already exists.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)

    }

    func isFolderNameExists(folderName: String) -> Bool {
        // Check if the folder name exists in the database
        if let folders = DatabaseHelper.instance.fetchFolders() {
            return folders.contains { (folder) -> Bool in
                if let name = folder.value(forKey: "name") as? String {
                    return name == folderName
                }
                return false
            }
        }
        return false
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func fetchAndUpdateCollectionView() {
        if let savedFolders = DatabaseHelper.instance.fetchFolders() {
            foldersName = savedFolders.compactMap { $0.value(forKey: "name") as? String }
            if isFilteredByFavorites {
                let favoriteFolders = savedFolders.filter { $0.value(forKey: "isFavorite") as? Bool ?? false }
                let favoriteFolderNames = favoriteFolders.compactMap { $0.value(forKey: "name") as? String }
                filteredFoldersName = favoriteFolderNames
            } else {
                filteredFoldersName = foldersName
            }
            
            folderCollectionView.reloadData()
        }
    }
    
}
