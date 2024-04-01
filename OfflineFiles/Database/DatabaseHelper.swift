//
//  DatabaseHelper.swift
//  OfflineFiles
//
//  Created by Giridharan on 30/03/24.
//

import Foundation
import CoreData
import UIKit


class DatabaseHelper {
    
    static let instance = DatabaseHelper()
    
    
    private init () {}
    
    
    lazy var managedContext : NSManagedObjectContext = {
        
        guard let appDelegate = UIApplication.shared.delegate as?  AppDelegate else {
            
            fatalError("Unable to access AppDelegate")
        }
        
        return appDelegate.persistentContainer.viewContext
        
    }()
    
    
    func saveFolder(name : String) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Folders", in: managedContext) else {
                fatalError("Unable to find entity description for 'Folders'")
            }
        
        let folder = NSManagedObject(entity: entity, insertInto: managedContext)
        
        folder.setValue(name, forKey: "name")
        
        
        do {
            try managedContext.save()
            print("Folder saved successfully.")
        }
        catch let error {
            
            print(error.localizedDescription)
        }
        
    }
    
    
    func fecthFolders() -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Folders")
        
        do {
            let folders = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            return folders
        }
        catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        
    }
    
    func deleteAllData(forEntity entityName: String) {
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
           let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
           
           do {
               try managedContext.execute(deleteRequest)
               print("All data deleted successfully for entity: \(entityName)")
           } catch let error as NSError {
               print("Error deleting all data for entity: \(entityName) - \(error.localizedDescription)")
           }
       }
    
    
    
    func saveImage(_ image: UIImage, fileName: String, toFolder folder: NSManagedObject) {
        guard let imageData = image.pngData() else {
            print("Failed to convert image to data.")
            return
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Images", in: managedContext) else {
            fatalError("Unable to find entity description for 'ImageEntity'")
        }
        
        let imageObject = NSManagedObject(entity: entity, insertInto: managedContext)
        imageObject.setValue(imageData, forKey: "image")
        imageObject.setValue(fileName, forKey: "fileName") 
        imageObject.setValue(folder, forKey: "folder")
        
        do {
            try managedContext.save()
            print("Image saved successfully.")
        } catch let error {
            print("Error saving image: \(error.localizedDescription)")
        }
    }


    func saveFile(atURL url: URL, toFolder folder: NSManagedObject) {
        guard let fileData = try? Data(contentsOf: url) else {
            print("Failed to read file data.")
            return
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Files", in: managedContext) else {
            fatalError("Unable to find entity description for 'FileEntity'")
        }
        
        let fileObject = NSManagedObject(entity: entity, insertInto: managedContext)
        fileObject.setValue(fileData, forKey: "files")
        fileObject.setValue(url.lastPathComponent, forKey: "fileName")
        fileObject.setValue(folder, forKey: "folder")
        
        do {
            try managedContext.save()
            print("File saved successfully.")
        } catch let error {
            print("Error saving file: \(error.localizedDescription)")
        }
    }
    
    func fetchImages(forFolder folder: NSManagedObject) -> [NSManagedObject]? {
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
           fetchRequest.predicate = NSPredicate(format: "folder == %@", folder)
           
           do {
               let images = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
               return images
           } catch {
               print("Error fetching images: \(error.localizedDescription)")
               return nil
           }
       }
       
       func fetchFiles(forFolder folder: NSManagedObject) -> [NSManagedObject]? {
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Files")
           fetchRequest.predicate = NSPredicate(format: "folder == %@", folder)
           
           do {
               let files = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
               return files
           } catch {
               print("Error fetching files: \(error.localizedDescription)")
               return nil
           }
       }

    
}
