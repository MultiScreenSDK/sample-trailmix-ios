import Foundation
import UIKit


extension UINavigationController {
    
    public override func supportedInterfaceOrientations() -> Int {
        return visibleViewController.supportedInterfaceOrientations()
    }
    public override func shouldAutorotate() -> Bool {
        return visibleViewController.shouldAutorotate()
    }
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return visibleViewController.preferredInterfaceOrientationForPresentation()
    }
}
