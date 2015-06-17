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


class DeviceVC: UITableViewController {
    
    var didFindServiceObserver: AnyObject? = nil
    
    var didRemoveServiceObserver: AnyObject? = nil

    var selectBlock: ((service: Service) -> Void)!

    var services: [Service] {
        return  self.helloVC!.services
    }

    weak var helloVC: HelloWorldVC? {
        didSet {
            if self.helloVC != nil  {
                didFindServiceObserver = self.helloVC!.search.on(MSDidFindService) { [unowned self] notification in
                    self.tableView.reloadData()
                }
                didRemoveServiceObserver = self.helloVC!.search.on(MSDidRemoveService) {[unowned self] notification in
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        if didFindServiceObserver != nil {
            self.helloVC!.search.off(didFindServiceObserver!)
        }
        if didRemoveServiceObserver != nil {
            self.helloVC!.search.off(didRemoveServiceObserver!)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.helloVC != nil {
            if self.helloVC!.search.isSearching {
                return services.count
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel!.text = services[indexPath.row].name
            cell.detailTextLabel!.text = services[indexPath.row].type
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Devices"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if helloVC!.search.isSearching {
            selectBlock!(service: services[indexPath.row])
        }
        dismissViewControllerAnimated(true) { }
    }

}