import SwiftUI

class Session: ObservableObject {

    func importBaseline() {
        let importService = ImportService()
        try? importService.importAll()
    }
}
