import Foundation
import CoreData

class ImportService {

    let backgroundContext: NSManagedObjectContext

    init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        self.backgroundContext = backgroundContext
    }

    func add(a: A) throws -> AEntity? {
        var aEntity: AEntity? = nil
        var thrownError: Error?

        backgroundContext.performAndWait {
            do {
                let foundA = get(a: a)
                let AToProcess = foundA != nil ? foundA! : CoreDataUtil.addRecord(AEntity.self, withContent: self.backgroundContext)
                print("--------------------------------------------")

                if let foundA = foundA {
                    print("Updating a: \(foundA.name ?? "")")
                    let foundRevision = foundA.revision as? Int
                    if foundRevision == a.revision {
                        print("Trying to update a a with the same revision (\(a.revision)). Skipping.")
                        print("--------------------------------------------")
                        return
                    }
                } else {
                    print("Creating a: \(a.name)")
                }

                AToProcess.name = a.name.trimmingCharacters(in: .whitespacesAndNewlines)
                AToProcess.retired = a.retired
                AToProcess.revision = a.revision as NSNumber?

                var updatedB = a.b

                var identicalRI = 0
                var addedRI = 0
                var retiredRI = 0
                if let bEntities = AToProcess.b {
                    for case let bEntity as BEntity in bEntities {
                        let mappedEntity = mapB(fromBEntity: bEntity)
                        if updatedB.contains(mappedEntity), let index = updatedB.firstIndex(of: mappedEntity) {
                            // delete valid entity from DTO so we don't add it again.
                            updatedB.remove(at: index)
                            identicalRI += 1
                        } else {
                            if bEntity.retired {
                                // already retired. Do nothing
                            } else {
                                bEntity.retired = true
                                retiredRI += 1
                            }
                        }
                    }
                }
                try backgroundContext.save()

                // 3. add new Bs (if any)
                let bEntitySet = AToProcess.b?.mutableCopy() as? NSMutableSet
                for b in updatedB {
                    let bEntity = CoreDataUtil.addRecord(BEntity.self, withContent: self.backgroundContext)

                    bEntity.name = b.name
                    bEntity.a = AToProcess
                    if let bEntitySet = bEntitySet {
                        bEntitySet.add(bEntity)
                    }

                    addedRI += 1
                }
                AToProcess.b = bEntitySet
                print("Updated Bs: [added: \(addedRI), retired: \(retiredRI), identical: \(identicalRI)]")

                aEntity = AToProcess
                print("--------------------------------------------")

                try backgroundContext.save()

            } catch let error as NSError {
                thrownError = error
            }
        }

        if let error = thrownError {
            throw error
        }

        return aEntity
    }

    func get(a: A) -> AEntity? {

        var results: [AEntity]?
        if let id = a.id, let objectID = try? CoreDataUtil.getManagedObjectID(byStringId: id, withContext: self.backgroundContext) {
            let fetchRequest = CoreDataUtil.fetchRequest(AEntity.self, search: NSPredicate(format: "self == %@", objectID))
            results = CoreDataUtil.query(AEntity.self, fetchRequest: fetchRequest, withContext: self.backgroundContext)
        }  else if !a.name.isEmpty {
            results = CoreDataUtil.query(AEntity.self, fetchRequest: Self.fetchRequestEquals(name: a.name), withContext: self.backgroundContext)
        }

        if let results = results {
            switch results.count {
            case 0:
                return nil
            case 1:
                return results.first
            default:
                print("WARNING: multiple records found for name: \(a.name). Returning first result.")
                return results.first
            }
        } else {
            return nil
        }
    }

    enum CoreDataUtilError: Error {
        case NSManagedObjectIDNotFoundForString
        case NSManagedObjectNotFound
    }


    // MARK: - Fetch Requests
    class func fetchRequestEquals(name: String) -> NSFetchRequest<AEntity> {
        let namePredicate = NSPredicate(format: "name ==[c] %@", name)
        return CoreDataUtil.fetchRequest(AEntity.self, search: namePredicate)
    }

    // MARK: - JSON Encode/Decode
    func decodeAs(fromURL url: URL) -> [A]? {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }

        return try? JSONDecoder().decode([A].self, from: data)
    }

    func importAll(fromJson json: String = "a") throws {
        guard let path = Bundle.main.path(forResource: json, ofType: "json"),
              let a = decodeAs(fromURL: URL(fileURLWithPath: path)) else {

            return
        }

        try a.forEach { a in
            let _  = try add(a: a)
        }
    }

    // MARK: - Entity to DTO map

    func mapA(fromAEntity entity: AEntity) -> A {

        var Bs: [B] = []
        if let BEntities = entity.b {
            for bEntity in BEntities {
                Bs.append(mapB(fromBEntity: bEntity as! BEntity))
            }
        }

        return A(
            id: entity.objectID.uriRepresentation().absoluteString,
            name: entity.name ?? "",
            b: Bs,
            retired: entity.retired,
            revision: entity.revision as? Int ?? 0
        )
    }

    func mapB(fromBEntity entity: BEntity) -> B {
        B(id: entity.objectID.uriRepresentation().absoluteString, name: entity.name ?? "", retired: entity.retired)
    }
}
