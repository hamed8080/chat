//
//  PSM.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/9/21.
//
// TLDR 'Persistance Service Manager'
import CoreData

class PSM {
    
    private init(){}
    static let shared = PSM()
    lazy var context: NSManagedObjectContext = persistentContainer.viewContext
    
     lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "CacheDataModel"
        var modelURL: URL
        if let bundle = Bundle(identifier: "org.cocoapods.FanapPodChatSDK") {
            modelURL = bundle.url(forResource: modelName, withExtension: "momd")!
        } else {
            modelURL = Bundle(for: Chat.self).url(forResource: modelName, withExtension: "momd")!
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing mom from: \(modelURL)") }
        let container = NSPersistentContainer(name: modelName ,managedObjectModel: mom )
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

   func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("saved successfuly")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }else{
            print("no changes find on context so nothing to save!")
        }
    }
}
