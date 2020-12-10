import Foundation
import CoreData

class CoreDataManager {

    let usePrivateStore: Bool

    lazy var persistentContainer: NSPersistentContainer! = {

        let container = NSPersistentCloudKitContainer(name: "Model")
        let defaultDescription = container.persistentStoreDescriptions.first
        let url = defaultDescription?.url?.deletingLastPathComponent()

        // Create a store description for a private CloudKit-backed local store
        let cloudStoreLocation = url!.appendingPathComponent("cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        var privateCloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.CoreDataSyncIssues")
        privateCloudKitContainerOptions.databaseScope = .private
        cloudStoreDescription.cloudKitContainerOptions = privateCloudKitContainerOptions
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // Create a store description for a public CloudKit-backed local store
        let publicCloudStoreLocation = url!.appendingPathComponent("cloud-public.sqlite")
        let publicCloudStoreDescription = NSPersistentStoreDescription(url: publicCloudStoreLocation)
        publicCloudStoreDescription.configuration = "CloudPublic"
        var publicCloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.CoreDataSyncIssues")
        publicCloudKitContainerOptions.databaseScope = .public
        publicCloudStoreDescription.cloudKitContainerOptions = publicCloudKitContainerOptions
        publicCloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        publicCloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if usePrivateStore {
            container.persistentStoreDescriptions = [cloudStoreDescription, publicCloudStoreDescription]
        } else {
            container.persistentStoreDescriptions = [publicCloudStoreDescription]
        }

        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else {
                return
            }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })

        container.persistentStoreCoordinator.persistentStores.forEach { store in
            print("\(store.configurationName): NSStoreUUID: \(store.metadata["NSStoreUUID"] as Any)")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true


//        do {
//            try container.initializeCloudKitSchema()
//        } catch (let error) {
//            fatalError("###\(#function): Unable to initialize CloudKit schema: \(error.localizedDescription)")
//        }

        return container
    }()

    static let shared = CoreDataManager()

    init() {
        #if os(iOS)
        self.usePrivateStore = true
        #else
        self.usePrivateStore = false
        #endif
    }
}