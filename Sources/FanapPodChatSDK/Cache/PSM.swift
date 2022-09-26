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
        if let bundleUrl = Bundle(identifier: "org.cocoapods.FanapPodChatSDK")?.url(forResource: modelName, withExtension: "momd") {
            modelURL = bundleUrl
        } else if let moduleUrl = Bundle.module.url(forResource: modelName, withExtension: "momd"){
            modelURL = moduleUrl
        } else {
            modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
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
                Chat.sharedInstance.logger?.log(title: "saved successfully", jsonString: nil)
            } catch {
                let nserror = error as NSError
                #if DEBUG
                    Chat.sharedInstance.logger?.log(title: "error occured in save database", message: "\(nserror), \(nserror.userInfo)")
                #else
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                #endif
            }
        }else{
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "no changes find on context so nothing to save!")
        }
    }
}
