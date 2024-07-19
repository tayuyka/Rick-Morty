import SwiftUI

class Character: Codable {
    let id: Int
    let name: String
    let status: String
    let gender: String
    let image: String
    let species: String
    let location: Location
    let episode: [String]
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id
    }
    
    var locationName: String {
            location.name
        }
    
    struct Location: Codable {
        let name: String
        let url: String
    }
    
    struct Episode: Codable {
        let id: Int
        let name: String
    }
    
    
    
    func getStatusColor() -> Color{
        var statusColor: Color
        
        switch self.status {
        case "Alive":
            statusColor = .green
        case "Dead":
            statusColor = .red
        default:
            statusColor = .gray
        }
        
        return statusColor
    }
}

struct CharactersResponse: Decodable {
    let info: Info
    let results: [Character]
}

struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
