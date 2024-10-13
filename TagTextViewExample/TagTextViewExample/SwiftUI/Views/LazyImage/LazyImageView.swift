import SwiftUI
import UIKit

struct LazyImageView: UIViewRepresentable {
    var data: ImageDataType?
    var tintColor: UIColor?
    var backgroundColor: UIColor?
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        if let contentMode = data?.contentMode {
            imageView.contentMode = contentMode
        }
        imageView.clipsToBounds = true
        if let tintColor {
            imageView.tintColor = tintColor
        }
        
        if let backgroundColor {
            imageView.backgroundColor = backgroundColor
        }
        
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.configure(with: data)
    }
}

#if DEBUG
#Preview("LazyImageView Image") {
    LazyImageView(data: .image(data: UIImage(systemName: "person.and.background.dotted"), contentMode: .scaleAspectFill))
}

#Preview("LegacyImageView Url") {
    LazyImageView(data: .network(url: URL(string: "https://via.assets.so/movie.png?id=1&q=95&w=360&h=360&fit=fill"),
                                 placeholder: UIImage(named: "person.circle"),
                                 contentMode: .scaleAspectFit))
}
#endif
