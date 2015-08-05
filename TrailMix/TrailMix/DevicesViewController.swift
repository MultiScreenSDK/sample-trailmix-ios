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
import MSF

class DevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    /// MultiScreenManager instance that manage the interaction with the services
    var multiScreenManager = MultiScreenManager.sharedInstance
    
    /// Temp array of services
    var services = [AnyObject]()
    
    /// Identifier for UITableview cell
    let devicesFoundCellID = "devicesFoundCell"
    
    @IBOutlet weak var devicesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /// Table row height
        self.devicesTableView.rowHeight = 44
        /// Configuring the tableView separator style
        devicesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: devicesFoundCellID)
        
        if devicesTableView.respondsToSelector("setSeparatorInset:") {
            devicesTableView.separatorInset = UIEdgeInsetsZero
        }
        if devicesTableView.respondsToSelector("setLayoutMargins:") {
            devicesTableView.layoutMargins = UIEdgeInsetsZero
        }
        
        
        devicesTableView.layoutIfNeeded()
        devicesTableView.tableFooterView = UIView(frame: CGRectZero)
        
        /// Add a gesture recognizer to dismiss the current view on tap
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: "closeView")
        self.view.addGestureRecognizer(tap)
        
        // Add an observer to check for services status and manage the cast icon
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTableView", name: multiScreenManager.servicesChangedObserverIdentifier, object: nil)
        
        refreshTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Reload table view with services not connected
    func refreshTableView(){
        
        /// Populate Temp services array with services not connected
        services = multiScreenManager.servicesCopy()
        
        devicesTableView.layoutIfNeeded()
        devicesTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return services.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        /// Setting the custom cell view
        var cell: UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier(devicesFoundCellID, forIndexPath: indexPath) as! UITableViewCell
        
        
        // Set tableView separator style
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.SingleLine
        
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        
        /// Adding color to the cell on click
        var selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        cell.selectedBackgroundView = selectedView
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        
        /// Adding the text for each cell
        cell.textLabel?.textColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        cell.textLabel?.textAlignment = .Left
        cell.textLabel?.frame.origin.x = -20
        
        if let displayName = services[indexPath.row].displayName {
            cell.textLabel?.text = services[indexPath.row].displayName
            //cell.textLabel?.attributedText = NSMutableAttributedString(string: "\(services[indexPath.row].name)", attributes: [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 14.0)!])
        }
        
        var image : UIImage = UIImage(named: "icon_cast_discovered")!
        cell.imageView!.image = multiScreenManager.isSpeaker(services[indexPath.row] as! Service) ? UIImage(named: "ic_speaker")! : UIImage(named: "ic_tv")!
        
        cell.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        //connectingIndicator.hidden = false
        //connectingIndicator.startAnimating()
        if (multiScreenManager.isConnected) {
            multiScreenManager.closeApplication({ (success: Bool!) -> Void in
                //
            })
        }
        
        var text: String = String("connecting to ")
        
        var hud = MBProgressHUD(view: self.view)
        let cgFloat: CGFloat = CGRectGetMinY(tableView.bounds);
        let someFloat: Float = Float(cgFloat)
        hud.yOffset = someFloat
        self.view.addSubview(hud)
        
        let toastMsg =  String("connecting to ") + (services[indexPath.row] as! Service).displayName
        
        hud.labelText = toastMsg
        hud.show(true)
        hud.dimBackground = true
        
        //title.text = "Connecting"
        /// If cell is selected then connect and start the application
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        multiScreenManager.createApplication(services[indexPath.row] as! Service, completionHandler: { (success: Bool!,error: NSError?) -> Void in
            hud.hide(true)
            self.closeView()
            if ((success) == false){
                var errorMsg: String? = String()
                if error != nil {
                    errorMsg = error!.localizedDescription
                } else {
                    errorMsg = "Connection could not be established"
                }
                var  alertView:UIAlertView = UIAlertView(title: "" as String, message: errorMsg, delegate: self, cancelButtonTitle: "OK")
                alertView.alertViewStyle = .Default
                alertView.show()
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(self.multiScreenManager.serviceConnectedObserverIdentifier, object: self)
            }
            })
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        headerView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(1)
        let label  = UILabel(frame: CGRect(x: 6, y: 0, width: headerView.bounds.size.width-12, height: 20))
        label.textAlignment = NSTextAlignment.Center
        label.text = "Connect to:"
        headerView.addSubview(label)
        return headerView
    }
    
    
    
    /// Capture the event when the disconnectButton button is clicked
    /// this will close the current service connection
    @IBAction func  closeApplication(){
        multiScreenManager.closeApplication({ [unowned self](success: Bool!) -> Void in
            self.closeView()
            })
        
    }
    
    /// Close the current View
    func closeView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view.tag == 1){
            return true
        }
        return false
    }
}
