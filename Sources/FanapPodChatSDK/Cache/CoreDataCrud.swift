//
//  CoreDataCrud.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/9/21.
//

import CoreData

open class CoreDataCrud<T:NSFetchRequestResult> {
    
    var entityName:String

    public init(entityName:String) {
        self.entityName = entityName
    }
    
    public func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: entityName)
    }
    
    public func getInsertEntity() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: PSM.shared.context) as! T
    }
    
    public func getFetchRequest() -> NSFetchRequest<T> {
        return NSFetchRequest<T>(entityName: entityName)
    }
    
    public func getAll()->[T]{
        return (try? PSM.shared.context.fetch(getFetchRequest())) ?? []
    }
    
    public func getTotalCount(predicate:NSPredicate? = nil)->Int{
        let req = fetchRequest()
        req.predicate = predicate
        return (try? PSM.shared.context.count(for: req)) ?? 0
    }
    
    public func fetchWith(_ fetchRequest:NSFetchRequest<NSFetchRequestResult>)->[T]?{
        return (try? PSM.shared.context.fetch(fetchRequest)) as? [T]
    }
    
    public func fetchWith(_ predicate:NSPredicate)->[T]?{
        let req = fetchRequest()
        req.predicate = predicate
        return (try? PSM.shared.context.fetch(req)) as? [T]
    }
    
    /// - todo: check key equality work with @ for string or int %i float %f and ...
    public func find(keyWithFromat:String, value:CVarArg)->T?{
        let req = getFetchRequest()
        req.predicate = NSPredicate(format: "\(keyWithFromat)", value)
        do {
            return try PSM.shared.context.fetch(req).first
        } catch {
            return nil
        }
    }
    
    public func delete(entity:NSManagedObject){
        PSM.shared.context.delete(entity)
    }
    
    public func deleteWith(predicate:NSPredicate){
        do{
            let req = fetchRequest()
            req.predicate = predicate
            let deleteReq = NSBatchDeleteRequest(fetchRequest: req)
            try PSM.shared.context.execute(deleteReq)
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "saved successfully from deleteWith execute")
        }catch{
            Chat.sharedInstance.logger?.log(title: "error in deleteWith happened", message: "\(error)")
        }
        
    }
    
    public func deleteAll(){
        do{
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest())
            deleteRequest.resultType = .resultTypeObjectIDs
            let batchDelete = try PSM.shared.context.execute(deleteRequest) as? NSBatchDeleteResult
            guard let deletedResult = batchDelete?.result as? [NSManagedObjectID] else {return}
            let deletedObjects :[AnyHashable:Any] = [NSDeletedObjectsKey : deletedResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [PSM.shared.context])
            Chat.sharedInstance.logger?.log(title: "saved successfully from deleteAll execute for table \(entityName)")
        }catch{
            Chat.sharedInstance.logger?.log(title: "error in deleteAll happened", message: "\(error)")
        }
    }
    
    public func insert(setEntityVariables:(T)->()){
        insertAll(setEntityVariables: setEntityVariables)
    }
    
    /// - warning: Please be sure using entity fetched from insertEntity method otherwise cant save
    public func insertAll(setEntityVariables:(T)->() ){
        PSM.shared.context.performAndWait{
            let entity = getInsertEntity()
            setEntityVariables(entity)
        }
    }
    
    public func fetchWithOffset(count:Int? , offset:Int? ,predicate:NSPredicate? , sortDescriptor:[NSSortDescriptor]? = nil) ->[T]{
        let req = fetchRequest()
        if let sortDescriptors = sortDescriptor{
            req.sortDescriptors = sortDescriptors
        }
        req.predicate = predicate
        req.fetchLimit = count ?? 50
        req.fetchOffset = offset ?? 0
        return fetchWith(req) ?? []
    }

}
