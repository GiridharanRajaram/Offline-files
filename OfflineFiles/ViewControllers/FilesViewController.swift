//
//  FilesViewController.swift
//  OfflineFiles
//
//  Created by Giridharan on 31/03/24.
//

import UIKit
import CoreData
import PDFKit

class FilesViewController: UIViewController {
    
    var selectedFolder: NSManagedObject?
    
    var selectedFiles: [URL] = []
    
    var selectedImages: [UIImage] = []
    
    var selectedFileName : [String] = []
    
    @IBOutlet weak var filesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FilesCollectionViewCell", bundle: nil)
        filesCollectionView.register(nib, forCellWithReuseIdentifier: "FilesCollectionViewCell")
        
        filesCollectionView.delegate = self
        filesCollectionView.dataSource = self
        
        filesCollectionView.reloadData()
        
        loadImages()
        loadFiles()
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
        
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
        
        present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func pickFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func loadImages() {
        guard let folder = selectedFolder else { return }
        
        if let images = DatabaseHelper.instance.fetchImages(forFolder: folder) {
            selectedImages = images.compactMap { imageObject in
                guard let imageData = imageObject.value(forKey: "image") as? Data,
                      let image = UIImage(data: imageData) else {
                    return nil
                }
                return image
            }
            
            selectedFileName = images.compactMap { imageObject in
                return imageObject.value(forKey: "fileName") as? String
            }
        } else {
            selectedImages = []
            selectedFileName = []
        }
        
        filesCollectionView.reloadData()
    }
    
    
    func loadFiles() {
        guard let folder = selectedFolder else { return }
        selectedFiles = DatabaseHelper.instance.fetchFiles(forFolder: folder)?.compactMap { fileObject in
            guard let fileName = fileObject.value(forKey: "fileName") as? String,
                  let fileURL = fileObject.value(forKey: "fileName") as? URL else {
                return nil
            }
            return fileURL
        } ?? []
        filesCollectionView.reloadData()
    }
    
    func saveFile(atURL url: URL) {
        selectedFiles.append(url)
        filesCollectionView.reloadData()
    }
    
    func saveImage(_ image: UIImage, fileName : String) {
        selectedImages.append(image)
        selectedFileName.append(fileName)
        filesCollectionView.reloadData()
    }
    
}

extension FilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count + selectedFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilesCollectionViewCell", for: indexPath) as! FilesCollectionViewCell
        
        if indexPath.item < selectedImages.count  &&  indexPath.item < selectedFileName.count  {
            let image = selectedImages[indexPath.item]
            let fileName = selectedFileName[indexPath.item]
            cell.configure(with: image, isDocument: false, fileName: fileName)
        } else {
            
            let fileURL = selectedFiles[indexPath.item - selectedImages.count]
            let fileURLName = fileURL.lastPathComponent
            selectedFileName.append(fileURLName)
            let fileName = selectedFileName[indexPath.item]
            if let pdfDocument = PDFDocument(url: fileURL), let pdfPage = pdfDocument.page(at: 0) {
                let pdfThumbnail = pdfPage.thumbnail(of: CGSize(width: 120, height: 120), for: .mediaBox)
                cell.configure(with: pdfThumbnail, isDocument: true, fileName: fileName)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120 , height: 120)
        
    }
}

extension FilesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if let imageURL = info[.imageURL] as? URL {
                let imageName = imageURL.lastPathComponent
                print("Picked image file name: \(imageName)")
                DatabaseHelper.instance.saveImage(image, fileName: imageName, toFolder: selectedFolder ?? NSManagedObject())
                saveImage(image, fileName: imageName)
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension FilesViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        DatabaseHelper.instance.saveFile(atURL: fileURL, toFolder: selectedFolder ?? NSManagedObject())
        saveFile(atURL: fileURL)
    }
}
