import Foundation

struct User: Codable {
    let name: String
    let age: Int
    let retired: Bool
    let father: String?
}
