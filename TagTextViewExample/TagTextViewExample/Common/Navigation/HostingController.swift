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
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.rootView.viewDidAppear(viewController: self, animated: animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        self.rootView.viewWillDisappear(viewController: self, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        self.rootView.viewDidDisappear(viewController: self, animated: true)
        super.viewDidDisappear(animated)
    }
}
