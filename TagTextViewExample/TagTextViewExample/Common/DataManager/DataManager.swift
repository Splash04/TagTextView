import Foundation
import SwiftUI

/// Manager that is responsible for providing data
final class DataManager {
    
    // ******************************* MARK: - Singleton
    
    static let shared = DataManager()
    private init() {}
    
    var imageCache: [String : Image] = [:]
    
    func fetchCharacters() async throws -> [FilmCharacter] {
        let url = URL(string: "https://hp-api.herokuapp.com/api/characters/")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode([FilmCharacter].self, from: data)
        return response
    }
}
