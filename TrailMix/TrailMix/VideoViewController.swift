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
        
        self.view.addSubview(moviePlayer.view)
        //moviePlayer.fullscreen = true

        moviePlayer.shouldAutoplay = false
        
        moviePlayer.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleRightMargin

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerLoadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidFinishPlaying:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidExitFullScreen:", name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
        
        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        
        
        moviePlayer.play()
        
        // Adding a tap recognizer to display the hidden navigation bar on tap
        var singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showNavigationBar")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        moviePlayer.view.addGestureRecognizer(singleTapGestureRecognizer)
        //self.view.addGestureRecognizer(singleTapGestureRecognizer)
        
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
        
    }
    
    func videoPlayerDidFinishPlaying(notification: NSNotification) {
        //moviePlayer.view.removeFromSuperview()
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func videoPlayerDidExitFullScreen(notification: NSNotification) {
        moviePlayer.controlStyle = MPMovieControlStyle.Embedded
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
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}




