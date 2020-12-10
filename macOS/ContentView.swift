
import SwiftUI

struct ContentView: View {

    @EnvironmentObject var session: Session

    var body: some View {
        Button(action: {
            session.importBaseline()
            print("Baseline imported")
        }) {
            Text("Import from JSON")
        }
    }
}
