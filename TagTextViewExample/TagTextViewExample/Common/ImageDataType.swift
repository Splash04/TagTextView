import UIKit
import AlamofireImage

// ******************************* MARK: - ImageDataType

enum ImageDataType: Hashable {
    case image(data: UIImage?, contentMode: UIView.ContentMode? = nil)
    case network(url: URL?, placeholder: UIImage?, contentMode: UIView.ContentMode? = nil)
}

// ******************************* MARK: - UIImageView

extension UIImageView {
    func configure(with imageData: ImageDataType?) {
        switch imageData {
        case .image(let data, let contentMode):
            if let contentMode {
                self.contentMode = contentMode
            }
            image = data
        case .network(let url, let placeholder, let contentMode):
            if let contentMode {
                self.contentMode = contentMode
            }
            setImage(withURL: url, placeholderImage: placeholder)
        case .none:
            image = nil
        }
    }
    
    func setImage(withURL url: URL?,
                  placeholderImage: UIImage? = nil,
                  imageTransition: UIImageView.ImageTransition = .noTransition) {
        if let url {
            af.setImage(withURL: url, placeholderImage: placeholderImage, imageTransition: imageTransition)
        } else {
            image = placeholderImage
        }
    }
}

// ******************************* MARK: - ImageDataType extension

extension ImageDataType {
    public var isEmpty: Bool {
        switch self {
        case .image(let data, _):
            return data == nil
        case .network(url: let url, placeholder: let placeholder, _):
            return url == nil && placeholder == nil
        }
    }
    
    var contentMode: UIView.ContentMode? {
        switch self {
        case .image(_, let contentMode):
            return contentMode
        case .network(url: _, _, let contentMode):
            return contentMode
        }
    }
}

// ******************************* MARK: - Constants

extension ImageDataType {
    static var profilePlaceholder: ImageDataType { .image(data: UIImage(systemName: "person.crop.circle"), contentMode: .scaleAspectFit) }
}
