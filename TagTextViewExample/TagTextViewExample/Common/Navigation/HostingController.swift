import SwiftUI
import UIKit

public class HostingController<ContentView>: UIHostingController<ContentView> where ContentView: ViewControllable {
    
    override public func loadView() {
        super.loadView()
        self.rootView.loadView()
    }
  
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rootView.viewWillAppear(viewController: self, animated: animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        self.rootView.viewDidDisappear(viewController: self, animated: true)
        super.viewDidDisappear(animated)
    }
}
