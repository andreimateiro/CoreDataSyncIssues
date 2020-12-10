import Foundation
import CoreData

class CoreDataUtil {

    class func addRecord<T: NSManagedObject>(_ type : T.Type, withContent context: NSManagedObjectContext) -> T {
        let entityName = T.description()
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let record = T(entity: entity!, insertInto: context)

        return record
    }

    class func query<T: NSManagedObject>(_ type : T.Type, fetchRequest: NSFetchRequest<T>, withContext context: NSManagedObjectContext) -> [T] {
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch failed. \(error), \(error.userInfo)")
            return []
        }
    }

    class func fetchRequest<T: NSManagedObject>(_ type : T.Type, search: NSPredicate? = nil, sort: [NSSortDescriptor]? = nil, limit: Int? = nil, fetchOffSet: Int? = nil) -> NSFetchRequest<T> {

        #if os(iOS)
        let request = NSFetchRequest<T>(entityName: T.className)
        #elseif os(macOS)
        let request = NSFetchRequest<T>(entityName: T.className())
        #endif

        if let predicate = search {
            request.predicate = predicate
        }

        if let sortDescriptors = sort {
            request.sortDescriptors = sortDescriptors
        } else {
            request.sortDescriptors = []
        }

        if let limit = limit {
            request.fetchLimit = limit
        }

        if let fetchOffSet = fetchOffSet {
            request.fetchOffset = fetchOffSet
        }

        return request
    }

    class func getManagedObjectID(byStringId string: String, withContext context: NSManagedObjectContext) throws -> NSManagedObjectID? {
        guard !string.isEmpty,
              string.starts(with: "x-coredata://"),
              let url = URL(string: string),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {

            print("Unable to read NSManagedObjectID from string.")
            throw CoreDataUtilError.NSManagedObjectIDNotFoundForString
        }

        return objectID
    }
}

extension NSObject {

    var className: String {
        String(describing: type(of: self))
    }

    class var className: String {
        String(describing: self)
    }
}


enum CoreDataUtilError: Error {
    case NSManagedObjectIDNotFoundForString
    case NSManagedObjectNotFound
}
