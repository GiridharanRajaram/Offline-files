//
//  FilesViewController.swift
//  OfflineFiles
//
//  Created by Giridharan on 31/03/24.
//

import UIKit
import CoreData

class FilesViewController: UIViewController {
    
    var selectedFolder: NSManagedObject?
    
    var selectedFilesUrls: [URL] = []
    
    var selectedFileName : [String] = []
    
    var selectedFilesData:[Data] = []
    
    let utilityFunctions = UtilityFunctions()
    
    @IBOutlet weak var filesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FilesCollectionViewCell", bundle: nil)
        filesCollectionView.register(nib, forCellWithReuseIdentifier: "FilesCollectionViewCell")
        
        filesCollectionView.delegate = self
        filesCollectionView.dataSource = self
        
        
        // Check if there are folders in CoreData
        if let folders = DatabaseHelper.instance.fetchFiles(forFolder: selectedFolder ?? NSManagedObject()), !folders.isEmpty {
              // If there are folders, hide the label
            utilityFunctions.hideEmptyFolderLabel(fromView: self.view)
          } else {
              // If there are no folders, show the label
              utilityFunctions.showEmptyFolderLabel(inView: self.view, title: "Click Folder icon to add folders")
          }
        loadFiles()
    }
    
    
  
    
    @IBAction func addfilesBtnAction(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let chooseImageAction = UIAlertAction(title: "Choose Image", style: .default) { _ in
            self.pickImage()
        }

        let chooseDocumentAction = UIAlertAction(title: "Choose Files", style: .default) { _ in
            self.pickFile()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        actionSheet.addAction(chooseImageAction)
        actionSheet.addAction(chooseDocumentAction)
        actionSheet.addAction(cancelAction)

        // Check if the device is iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }

        present(actionSheet, animated: true, completion: nil)

    }
    
}




