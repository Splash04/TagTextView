import UIKit

struct FilmCharacter: Decodable, Identifiable {
    let id: String
    let name: String?
    let house: String?
    let actor: String?
    let image: String?
    enum CodingKeys: String, CodingKey {
        case id, name, house, actor, image
    }
}

extension FilmCharacter {
    var profileImageData: ImageDataType {
        guard let image, let imageUrl = URL(string: image) else {
            return .profilePlaceholder
        }
        return .network(
            url: imageUrl,
            placeholder: UIImage(systemName: "person.crop.circle"),
            contentMode: .scaleAspectFill
        )
    }
}
