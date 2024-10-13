import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func openSwiftUI(_ sender: Any) {
        let postListView = ChatScreen(
            holder: NavigationStackHolder(),
            viewModel: ChatViewModel())
        let vc = postListView.viewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openUIKit(_ sender: Any) {
    }
    
}

