//
//  FilesViewControllerExtensions.swift
//  OfflineFiles
//
//  Created by Giridharan on 07/04/24.
//

import Foundation
import UIKit
import PDFKit
import QuickLookThumbnailing
import QuickLook
import CoreData


extension FilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFilesUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilesCollectionViewCell", for: indexPath) as! FilesCollectionViewCell
           
           let fileName = selectedFileName[indexPath.item]
           let fileUrl = selectedFilesUrls[indexPath.item]
           let fileData = selectedFilesData[indexPath.item]
        
         
        generateThumbnail(for: fileUrl, withData: fileData) { thumbnailImage in
               if let thumbnail = thumbnailImage {
                   cell.configure(with: thumbnail, isDocument: true, fileName: fileName)
               } else {
                   print(fileUrl)
               }
           }
           
           return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120 , height: 120)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = indexPath.item
        present(previewController, animated: true, completion: nil)
    }

  
}

extension FilesViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return selectedFilesUrls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let fileUrl = selectedFilesUrls[index]
        let fileExtension = fileUrl.pathExtension.lowercased()
        let isImageFile = ["jpg", "jpeg", "png", "gif", "svg", "pdf"].contains(fileExtension)

        if isImageFile {
               let temporaryDirectory = FileManager.default.temporaryDirectory
               let temporaryFileUrl = temporaryDirectory.appendingPathComponent("preview_image\(index).\(fileExtension)")
               do {
                   try selectedFilesData[index].write(to: temporaryFileUrl)
               } catch {
                   print("Error writing image data to temporary file: \(error)")
               }
               return temporaryFileUrl as QLPreviewItem
           } else {
               return fileUrl as QLPreviewItem
           }
    }
}

extension FilesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageURL = info[.imageURL] as? URL else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        let imageName = imageURL.lastPathComponent
        print("Picked image file name: \(imageName)")
        print(imageURL)
     
        guard let fileData = try? Data(contentsOf: imageURL) else {
            print("Failed to read file data.")
            return
        }
        DatabaseHelper.instance.saveFile(atURL: imageURL, withData: fileData, toFolder: selectedFolder ?? NSManagedObject())
        
        self.loadFiles()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension FilesViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        guard let fileData = try? Data(contentsOf: fileURL) else {
            print("Failed to read file data.")
            return
        }
        DatabaseHelper.instance.saveFile(atURL: fileURL, withData: fileData, toFolder: selectedFolder ?? NSManagedObject())
        loadFiles()
    }
    
}

extension FilesViewController {
    
    
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        utilityFunctions.hideEmptyFolderLabel(fromView: self.view)
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func pickFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        utilityFunctions.hideEmptyFolderLabel(fromView: self.view)
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    
    func loadFiles() {
        guard let folder = selectedFolder else { return }
        
        if let files = DatabaseHelper.instance.fetchFiles(forFolder: folder) {
            selectedFilesUrls = files.compactMap { fileObject in
                guard let fileUrl = fileObject.value(forKey: "fileURL") as? URL else {
                    return nil
                }
                return fileUrl
            }
            
            selectedFilesData = files.compactMap { fileObject in
                guard let fileData = fileObject.value(forKey: "fileData") as? Data else {
                    return nil
                }
                return fileData
            }
           
            selectedFileName = files.compactMap { fileObject in
                return fileObject.value(forKey: "fileName") as? String
            }
        } else {
            selectedFileName = []
        }
        filesCollectionView.reloadData()
    }
    
}



func generateThumbnail(for imageURL: URL, withData data : Data,  completion: @escaping (UIImage?) -> Void) {
    let size = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    let request = QLThumbnailGenerator.Request(fileAt: imageURL, size: size, scale: scale, representationTypes: .all)
    
    let generator = QLThumbnailGenerator.shared
    generator.generateRepresentations(for: request) { thumbnail, type, error in
        DispatchQueue.main.async {
            if thumbnail == nil || error != nil {
               let thumbnailImage =  UIImage(data: data)
                completion(thumbnailImage)
            } else {
                completion(thumbnail?.uiImage)
            }
        }
    }
}
