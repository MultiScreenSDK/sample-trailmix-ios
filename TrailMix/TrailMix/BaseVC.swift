/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import UIKit

/// BaseVC, it's a reusable UIViewController
///
/// Base class for other View Controllers to reuse methods
/// for the navigation bar
class BaseVC: UIViewController, UIGestureRecognizerDelegate {
    
    /// MultiScreenManager instance that manages the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// UIView that contains a list of available services
    //var servicesView: ServicesView!
    
    /// Cast icon Image variable
    var imageCastButton: UIImage!
    
    var imageConnectedCastButton: UIImage!
    var imageDisconnectedCastButton: UIImage!
    var castButton: UIButton!
    var castBarButton: UIBarButtonItem!

    /// Alert view to displaye popup messages
    var alertView: UIAlertView!
    
    var idVideoSelectedInMobile: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageConnectedCastButton = UIImage(named: "icon_cast_connect")
        imageDisconnectedCastButton = UIImage(named: "icon_cast_discovered")
        
        /// Configuring cast icon
        castButton = UIButton(frame: CGRectMake(0, 0, 22, 22))
        castButton.addTarget(self, action: Selector("showCastMenuView"), forControlEvents: UIControlEvents.TouchUpInside)
        castButton.setBackgroundImage(imageDisconnectedCastButton, forState: UIControlState.Normal)
        castBarButton = UIBarButtonItem(customView: castButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setCastIcon", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        //configure the Cast icon and Settings icon
        setCastIcon()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
    }
    
    /// Add or remove the cast icon from the Navigation bar
    /// Called by the servicesChanged observer
    func setCastIcon() {
        /// Show cast icon only if atleast one service/TV is available
        if (multiScreenManager.services.count > 0 || multiScreenManager.isConnected){
            
            if (multiScreenManager.isConnected == true){
                castButton.setBackgroundImage(imageConnectedCastButton, forState: UIControlState.Normal)
            }
            else {
                castButton.setBackgroundImage(imageDisconnectedCastButton, forState: UIControlState.Normal)
            }
            self.navigationItem.rightBarButtonItems = [castBarButton]
        }
        else {
            self.navigationItem.rightBarButtonItems = nil
        }
    }
    
    /// Shows a list of available services
    /// User can connect to a service
    /// User can disconnect from a connected service
    func showCastMenuView(){
        if multiScreenManager.isConnected {
            showDisconnectPopover()
        } else {
            showDevices()
        }
    }
    
    /// Shows the Devices List
    ///
    func showDevices() {
        
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("DevicesViewController") as! DevicesViewController
        
        popoverVC.modalTransitionStyle = .CrossDissolve
        popoverVC.view.backgroundColor = UIColor.clearColor()
        
        popoverVC.modalPresentationStyle = .Popover
        
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let beView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        beView.tag = 1
        beView.frame = self.view.bounds;
        beView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        popoverVC.view.frame = self.view.bounds
        popoverVC.view.insertSubview(beView, atIndex: 0)
        popoverVC.view.tag = 1
        // Present it before configuring it
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    func showDisconnectPopover() {
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("DeviceDisconnectViewController") as! DeviceDisconnectViewController
        popoverVC.modalTransitionStyle = .CrossDissolve
        popoverVC.view.backgroundColor = UIColor.clearColor()
        
        popoverVC.modalPresentationStyle = .OverCurrentContext
        
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let beView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        beView.tag = 1
        beView.frame = self.view.bounds;
        beView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        popoverVC.view.frame = self.view.bounds
        
        popoverVC.view.insertSubview(beView, atIndex: 0)
        popoverVC.view.tag = 1
        // Present it before configuring it
        presentViewController(popoverVC, animated: true, completion: nil)
        
    }
}
