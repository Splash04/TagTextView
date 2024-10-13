import SwiftUI
import UIKit

public protocol ViewControllable: View {
    var holder: NavigationStackHolder { get set }
  
    func loadView()
    func viewWillAppear(viewController: UIViewController, animated: Bool)
    func viewDidDisappear(viewController: UIViewController, animated: Bool)
}

public extension ViewControllable {
    
    var viewController: UIViewController {
        let viewController = HostingController(rootView: self)
        self.holder.viewController = viewController
        return viewController
    }
  
    func loadView() {}
    func viewWillAppear(viewController: UIViewController, animated: Bool) {}
    func viewDidDisappear(viewController: UIViewController, animated: Bool) {}
}
