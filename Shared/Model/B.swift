import Foundation

struct B: Identifiable, Hashable, Equatable, Codable {

    var id: String?
    var name: String
    var retired: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(retired)
    }

    static func ==(lhs: B, rhs: B) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        if lhs.retired != rhs.retired {
            return false
        }
        return true
    }
}


