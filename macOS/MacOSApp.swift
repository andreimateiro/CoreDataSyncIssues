import SwiftUI

@main
struct MacOSApp: App {
    var coreDataManager: CoreDataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                    .environment(\.managedObjectContext, coreDataManager.mainContext)
                    .environmentObject(Session())
        }
    }
}
