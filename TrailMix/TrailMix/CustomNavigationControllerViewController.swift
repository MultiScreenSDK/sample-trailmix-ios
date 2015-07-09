//
//  CustomNavigationControllerViewController.swift
//  TrailMix
//
//  Created by Prasath Thurgam on 7/7/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class CustomNavigationControllerViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    internal override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    internal override func shouldAutorotate() -> Bool {
        return true
    }
//    internal override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
//        return visibleViewController.preferredInterfaceOrientationForPresentation()
//    }
}
