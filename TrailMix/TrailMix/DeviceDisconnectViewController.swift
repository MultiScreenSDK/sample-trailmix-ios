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

class DeviceDisconnectViewController: UIViewController, UIGestureRecognizerDelegate {

    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    @IBOutlet weak var containerView: UIView!
    
    
    @IBOutlet weak var connectedDeviceImageView: UIImageView!
    
    @IBOutlet weak var connectedDeviceLabel: UILabel!
    
    @IBOutlet weak var disconnectButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        containerView.layer.masksToBounds = true
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOpacity = 0.6
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        //containerView.layer.borderWidth = 0.1
        //containerView.layer.borderColor = UIColor.blackColor().CGColor

        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: "closeView")
        self.view.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        if multiScreenManager.app != nil {
            connectedDeviceLabel?.text = "\(multiScreenManager.app.service.displayName)"
        }
        connectedDeviceImageView.image = multiScreenManager.isSpeaker(multiScreenManager.app.service) ? UIImage(named: "ic_speaker_gray")! : UIImage(named: "ic_tv_gray")!
        
        //disconnectButton.tintColor = self.userColor?.stringToColor()
    }
    
    @IBAction
    func disconnect() {
        multiScreenManager.closeApplication({ (success: Bool!) -> Void in
            //
        })
    }

    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
    
    /// Close the current View
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
