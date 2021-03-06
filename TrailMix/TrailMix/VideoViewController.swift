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
    var videoTitle: String!

    private var navBarHideSyncTimer: NSTimer? = nil
    internal var hideTimeout: NSTimeInterval = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url:NSURL = NSURL(string: urlString)!
        
        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.prepareToPlay()
        moviePlayer.view.frame = self.view.frame
        moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        moviePlayer.view.tag = 1
        moviePlayer.scalingMode = MPMovieScalingMode.Fill
        
        
        self.view.addSubview(moviePlayer.view)
        

        moviePlayer.shouldAutoplay = false
        
        moviePlayer.view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleRightMargin]

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerLoadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerPlayStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidFinishPlaying:", name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidExitFullScreen:", name: MPMoviePlayerDidExitFullscreenNotification, object: moviePlayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerWillExitFullScreen:", name: MPMoviePlayerWillExitFullscreenNotification, object: moviePlayer)
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        
        moviePlayer.play()
        
        // Adding a tap recognizer to display the hidden navigation bar on tap
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showNavigationBar")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        singleTapGestureRecognizer.delegate = self
        moviePlayer.view.addGestureRecognizer(singleTapGestureRecognizer)
        //self.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        let barButtonTitle = "<  \(videoTitle)"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: barButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "doneVideoPlayer")
        let font = UIFont(name: "Arial", size: 14)
        if let font2 = font {
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : font2, NSForegroundColorAttributeName : UIColor.whiteColor()], forState: UIControlState.Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func videoPlayerLoadStateDidChange(notification: NSNotification) {
        self.navBarHideSyncTimer?.invalidate()
        self.navBarHideSyncTimer = nil
        self.navBarHideSyncTimer = NSTimer.scheduledTimerWithTimeInterval(self.hideTimeout, target: self, selector: Selector("showNavigationBarByTimer"), userInfo: nil, repeats: false)
    }
    
    func videoPlayerPlayStateDidChange(notification: NSNotification) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navBarHideSyncTimer?.invalidate()
        self.navBarHideSyncTimer = nil
        self.navBarHideSyncTimer = NSTimer.scheduledTimerWithTimeInterval(self.hideTimeout, target: self, selector: Selector("showNavigationBar"), userInfo: nil, repeats: false)
        if moviePlayer.playbackState == MPMoviePlaybackState.Stopped || moviePlayer.playbackState == MPMoviePlaybackState.Paused {
            multiScreenManager.paused = true
        } else {
            multiScreenManager.paused = false
        }
        
        multiScreenManager.videoTime = moviePlayer.currentPlaybackTime
    }
    
    
    
    func videoPlayerDidFinishPlaying(notification: NSNotification) {
        doneVideoPlayer()
    }
    
    func videoPlayerDidExitFullScreen(notification: NSNotification) {

    }
    
    func videoPlayerWillExitFullScreen(notification: NSNotification) {
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
            self.navBarHideSyncTimer = NSTimer.scheduledTimerWithTimeInterval(self.hideTimeout, target: self, selector: Selector("showNavigationBar"), userInfo: nil, repeats: false)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            navBarHideSyncTimer?.invalidate()
            navBarHideSyncTimer = nil
        }
    }
    func showNavigationBarByTimer() {
        showNavigationBar()
    }
    func serviceConnected() {
        doneVideoPlayer()
    }
    
    /// UIGestureRecognizerDelegate used to disable the tap event if the tapped View is not the main View
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if (touch.view!.tag == 1){
            showNavigationBar()
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func doneVideoPlayer() {
        multiScreenManager.videoTime = moviePlayer.currentPlaybackTime
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func test() {
        
        if navBarHideSyncTimer != nil {
            navBarHideSyncTimer?.invalidate()
            navBarHideSyncTimer = nil
        }
    }
}





