//
//  VideoViewController.swift
//  TrailMix
//
//  Created by Prasath Thurgam on 6/10/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoViewController: BaseVC {

    var moviePlayer:MPMoviePlayerController!
    var urlString: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.navigationController?.hidesBarsOnTap = true
        
        //return
        //var url:NSURL = NSURL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!
        //var url:NSURL = NSURL(string: "http://www.ebookfrenzy.com/ios_book/movie/movie.mov")!
        
        var url:NSURL = NSURL(string: urlString)!
        
        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.prepareToPlay()
        //moviePlayer.view.frame = CGRect(x: 0, y: 70, width: self.view.frame.width, height: self.view.frame.height-70)
        moviePlayer.view.frame = self.view.frame
        moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        moviePlayer.shouldAutoplay = true
        moviePlayer.view.tag = 1
        
        self.view.addSubview(moviePlayer.view)
        
        

        moviePlayer.shouldAutoplay = false
        
        moviePlayer.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleRightMargin

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerLoadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidFinishPlaying:", name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidExitFullScreen:", name: MPMoviePlayerDidExitFullscreenNotification, object: moviePlayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerWillExitFullScreen:", name: MPMoviePlayerWillExitFullscreenNotification, object: moviePlayer)
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        
        moviePlayer.play()
        
        // Adding a tap recognizer to display the hidden navigation bar on tap
        var singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showNavigationBar")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        singleTapGestureRecognizer.delegate = self
        moviePlayer.view.addGestureRecognizer(singleTapGestureRecognizer)
        //self.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "done", style: UIBarButtonItemStyle.Done, target: self, action: "doneVideoPlayer")
        
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

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func videoPlayerLoadStateDidChange(notification: NSNotification) {
            //moviePlayer.fullscreen = true
    }
    
    func videoPlayerDidFinishPlaying(notification: NSNotification) {
        //moviePlayer.view.removeFromSuperview()
        //self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popToRootViewControllerAnimated(true)
        //self.dismissViewControllerAnimated(true, completion: nil)
        println(notification.userInfo)
        doneVideoPlayer()
    }
    
    func videoPlayerDidExitFullScreen(notification: NSNotification) {
        //moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        println(notification.userInfo)
        return
        let userInfo = notification.userInfo as! [String:AnyObject]
        let reason: AnyObject? = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
        let finishReason = MPMovieFinishReason(rawValue: reason!.integerValue)
        
        if MPMovieFinishReason.UserExited == finishReason {
            doneVideoPlayer()
        }

    }
    
    func videoPlayerWillExitFullScreen(notification: NSNotification) {
        println(notification.userInfo)
        //moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        let userInfo = notification.userInfo as! [String:AnyObject]
        if let reason: AnyObject? = notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber  {
            if let theReason: AnyObject = reason {
                let reasonValue = MPMovieFinishReason(rawValue: reason!.integerValue)
                
                if MPMovieFinishReason.UserExited == reasonValue {
                    doneVideoPlayer()
                }
            }
        }
        
        
        
        
    }
    
    
    
    /// Display the hidden navigation bar
    func showNavigationBar(){
        if ((self.navigationController?.navigationBar.hidden) == true){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
    }
    func serviceConnected() {
        doneVideoPlayer()
    }
    
    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        //println(touch.view.tag)
        if (touch.view.tag == 1){
            return true
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
        
    func doneVideoPlayer() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}





