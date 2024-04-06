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
    
    func deleteFolder(name: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let folderToDelete = results.first as? NSManagedObject {
                managedContext.delete(folderToDelete)
                try managedContext.save()
                print("Folder '\(name)' deleted successfully.")
            } else {
                print("Folder '\(name)' not found.")
            }
        } catch let error {
            print("Failed to delete folder: \(error.localizedDescription)")
        }
    }
    
    
    func saveColorForFolder(at index: Int, color: UIColor) {
        guard let folders = DatabaseHelper.instance.fetchFolders(), index < folders.count else { return }
        
        let folder = folders[index]
        
        guard let managedContext = folder.managedObjectContext else {
            fatalError("Managed Context not found for folder")
        }
        
        guard NSEntityDescription.entity(forEntityName: "Folders", in: managedContext) != nil else {
            fatalError("Unable to find entity description for 'Folders'")
        }
        

        let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        folder.setValue(colorData, forKey: "color")
     
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
 
    
    func fetchFolders() -> [NSManagedObject]? {
        
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
    
    
    func fetchFoldersSortedByDate() -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Folders")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let folders = try managedContext.fetch(fetchRequest)
            return folders
        } catch {
            print("Error fetching folders: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func saveContext() {
         do {
             try managedContext.save()
             print("Changes saved successfully.")
         } catch {
             print("Error saving context: \(error.localizedDescription)")
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

    func saveFile(atURL url: URL, withData data : Data, toFolder folder: NSManagedObject) {
        
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Files", in: managedContext) else {
            fatalError("Unable to find entity description for 'FileEntity'")
        }
        
        let fileObject = NSManagedObject(entity: entity, insertInto: managedContext)
        fileObject.setValue(data, forKey: "fileData")
        fileObject.setValue(url, forKey: "fileURL")
        fileObject.setValue(url.lastPathComponent, forKey: "fileName")
        fileObject.setValue(folder, forKey: "folder")
        do {
            try managedContext.save()
            print("File saved successfully.")
        } catch let error {
            print("Error saving file: \(error.localizedDescription)")
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
