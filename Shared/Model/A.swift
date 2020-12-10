import Foundation

struct A: Identifiable, Hashable, Equatable, Codable {

    var id: String?
    var name: String
    var b: [B]
    var retired: Bool = false
    var revision: Int = 0

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(b)
        hasher.combine(retired)
        hasher.combine(revision)
    }

    static func ==(lhs: A, rhs: A) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        if lhs.b != rhs.b {
            return false
        }
        if lhs.retired != rhs.retired {
            return false
        }
        if lhs.revision != rhs.revision {
            return false
        }
        return true
    }
}
