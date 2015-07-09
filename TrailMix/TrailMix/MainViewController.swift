//
//  ViewController.swift
//  TrailMix
//
//  Created by Prasath Thurgam on 6/10/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: BaseVC,UITableViewDataSource, UITableViewDelegate {

    var videos = NSMutableOrderedSet()
    var userColor: String = String("#E91E63")
    var color: UIColor = UIColor()
    
    @IBOutlet weak var videosTableView: UITableView!
    
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var videoSlider: UISlider!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var videoInfoLabel: UILabel!
    
    @IBAction func resumePauseButtonPressed(sender: AnyObject) {
        if self.currentVideoState == "playing" {
            multiScreenManager.sendResumePause(false)
        } else if self.currentVideoState == "paused" {
            multiScreenManager.sendResumePause(true)
        } else {
            multiScreenManager.sendResumePause(false)
        }
    }
    
    
    @IBAction func videoSliderValueChanged(sender: AnyObject) {
        multiScreenManager.sendSeek(Int(videoSlider.value))
    }
    var videoDuration: Int = 0
    
    var currentVideoState = String("unknown")
    var currentVideoId: String = String()
    
    var videoInfoViewRect: CGRect?
    var videosTableViewRect: CGRect?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let image = UIImage.imageWithColor(UIColor.blackColor())
        videoInfoViewRect = videoInfoView.frame
        videosTableViewRect = videosTableView.frame
        

        color = self.userColor.stringToColor()
        
        
        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.translucent = false
        
        
        
        
        multiScreenManager.startSearching()
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        let session = NSURLSession(configuration: config)
        
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: "http://dev-multiscreen.samsung.com/examples/trailmix/trailers/library.json")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) { [unowned self]  () -> Void in
            
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if (error == nil) {
                    
                    let httpResp = response as! NSHTTPURLResponse
                    if httpResp.statusCode == 200 {
                        
                        var serializationError: NSError?
                        let mediaData: [Dictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &serializationError) as! [[String:AnyObject]]
                        
                        if (serializationError == nil) {
                            let mediaInfos = mediaData.map {VideoItem(title: $0["title"] as! String, fileURL: $0["file"] as! String, thumbnailURL: $0["cover"] as! String!, duration: ($0["duration"] as? Int)!,id: $0["id"] as! String, year: $0["year"] as! String, cast: $0["cast"] as! String, type: $0["type"] as! String)}
                            
                            self.videos.addObjectsFromArray(mediaInfos)
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.videosTableView.reloadData()
                            })
                            
                        }
                    }
                }
            })
            
            dataTask.resume()
        }
        
        self.videosTableView.tableFooterView = UIView(frame: CGRectZero)
        
        if videosTableView.respondsToSelector("setSeparatorInset:") {
            videosTableView.separatorInset = UIEdgeInsetsZero
        }
        if videosTableView.respondsToSelector("setLayoutMargins:") {
            videosTableView.layoutMargins = UIEdgeInsetsZero
        }
        //self.videoInfoLabel.sizeToFit()

        // Add an observer to check if a tv is connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceConnected", name: multiScreenManager.serviceConnectedObserverIdentifier, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissQueueVC", name: multiScreenManager.dismissQueueVCObserverIdentifier, object: nil)
        
        // Add an observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentStatus:", name: multiScreenManager.currentTrackStatusObserverIdentifier, object: nil)
        
        videoSlider.addTarget(self, action: Selector("slidingStopped"), forControlEvents: UIControlEvents.TouchUpInside)
        videoSlider.addTarget(self, action: Selector("slidingStopped"), forControlEvents: UIControlEvents.TouchUpOutside)
        videoSlider.addTarget(self, action: Selector("slidingStarted"), forControlEvents: UIControlEvents.TouchDragInside)
        videoSlider.tintColor = color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.hidesBarsOnTap = false
        setupView()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return videos.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCellID", forIndexPath: indexPath) as! VideoTableViewCell
        
        // Configure the cell...
        
        var imageURL: String? = (videos.objectAtIndex(indexPath.row) as! VideoItem).thumbnailURL
        
        cell.videoInfoLabel.text = (videos.objectAtIndex(indexPath.row) as! VideoItem).title
        cell.videoInfoLabel.sizeToFit()
        
        
        // Set tableView separator style
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.SingleLine
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        cell.videoThumbnailImageView.image = UIImage(named: "album_placeholder")
        if let imageURLEncoded = imageURL!.URLEncodedString() {
            
            let url = NSURL(string: imageURLEncoded)
            cell.videoThumbnailImageView.setImageWithUrl(url!, placeHolderImage: UIImage(named: "album_placeholder"))

        }
        return cell
    }
    
    
    // returns nil if cell is not visible or index path is out of range
//    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell?  {
//        if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? MediaTableViewCell {
//            return updateCell
//        }
//        return nil
//    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !multiScreenManager.isConnected {
            let url = (videos.objectAtIndex(indexPath.row) as! VideoItem).fileURL
            let videoViewNavController = storyboard?.instantiateViewControllerWithIdentifier("VideoViewNavController") as! UINavigationController
            videoViewNavController.navigationBar.barTintColor = color
            videoViewNavController.navigationBar.translucent = false
            let videoViewController = videoViewNavController.viewControllers[0] as! VideoViewController
            videoViewController.urlString = url
            //self.navigationController?.pushViewController(videoViewController, animated: true)
            self.presentViewController(videoViewNavController, animated: true, completion: nil)
        } else {
            let videoInfo = videos.objectAtIndex(indexPath.row) as! VideoItem
            videoDuration = videoInfo.duration!
            self.videoSlider.minimumValue = 0.0
            self.videoSlider.maximumValue = Float(videoDuration)
            self.videoSlider.value = 0.0
            multiScreenManager.sendPlayVideo(videoInfo)
        }
        
//        var url:NSURL = NSURL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!
//        let urlString = (videos.objectAtIndex(indexPath.row) as! VideoItem).fileURL
//        var url2:NSURL = NSURL(string: urlString!)!
//        let moviePlayerVC = MyVideoPlayerController(contentURL: url2)
//        moviePlayerVC.moviePlayer.controlStyle = MPMovieControlStyle.None
//        self.navigationController?.presentMoviePlayerViewControllerAnimated(moviePlayerVC)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setupView() {
        //return
        if multiScreenManager.isConnected {
            videoInfoView.hidden = false
            //videosTableView.frame = videoInfoView.frame
            videosTableView.frame = CGRect(x: videoInfoView.frame.origin.x, y: videoInfoView.frame.origin.x + videoInfoView.frame.size.height+1, width: self.view.frame.width, height: self.view.frame.height)
            
            //self.videosTableView.reloadData()
            println(videosTableView.frame)
            self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
            self.videoSlider.minimumValue = 0.0
            self.videoSlider.maximumValue = Float(videoDuration)
            self.videoSlider.value = 0.0
        } else {
            
            println("%%%%%%%%%%%%%")
            println(videosTableView.frame.width)
            println(videosTableView.frame.height)
            
            videosTableView.frame = CGRect(origin: videoInfoView.frame.origin, size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            //self.videosTableView.reloadData()
            videoInfoView.hidden = false
            
            println(videosTableView.frame)
            self.navigationController?.navigationBar.barTintColor = color
        }
    }
    
    func serviceConnected() {
        setCastIcon()
        
        setupView()
        
        if (self.navigationItem.leftBarButtonItem != nil) {
            let label = self.navigationItem.leftBarButtonItem?.customView?.viewWithTag(100) as! UILabel
            label.text = multiScreenManager.app.service.name
        }
        
        videoSlider.hidden = true
        playPauseButton.hidden = true
        videoInfoLabel.hidden = true
        multiScreenManager.sendAppStateRequest()
    }
    
    /// dismisses the Queue/PlayList View Controller
    ///
    func dismissQueueVC() {
        if (self.navigationItem.leftBarButtonItem != nil) {
            let label = self.navigationItem.leftBarButtonItem?.customView?.viewWithTag(100) as! UILabel
            label.text = "TrailMix"
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        setupView()
    }
    
    func updateCurrentStatus(notification: NSNotification) {
        let userInfo: [String:AnyObject] = notification.userInfo as! [String:AnyObject]
        if let currentStatusDict = (userInfo["userInfo"] as? [String:AnyObject]) {
            self.currentVideoId = currentStatusDict["id"] as! String
            self.currentVideoState = currentStatusDict["state"] as! String
            
            let currentTime = currentStatusDict["time"] as! NSNumber
            let fTime = Float(currentTime)
            videoDuration = currentStatusDict["duration"] as! Int
            self.videoSlider.minimumValue = 0.0
            self.videoSlider.maximumValue = Float(videoDuration)
            if !multiScreenManager.sliding {
                videoSlider.setValue(fTime, animated: true)
                println("setvalue \(fTime)")
            }
            else {
                println("sliding, so no setvalue")
            }
            videoInfoLabel.text = currentStatusDict["title"] as? String
            
            //videoInfoLabel.sizeToFit()
            
            playPauseButton.setBackgroundImage(self.currentVideoState == "playing" ? UIImage(named: "ic_pause_dark"): UIImage(named: "ic_play_dark"), forState: UIControlState.Normal)
            
            videoInfoLabel.hidden = false
            videoSlider.hidden = false
            playPauseButton.hidden = false
        }
    }
    func slidingStarted() {
        multiScreenManager.sliding = true
        multiScreenManager.slidingIgnoreEvents = 3
    }
    
    func slidingStopped() {
        multiScreenManager.sliding = false
    }
    
    /*
    override func supportedInterfaceOrientations() -> Int {
        return  Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    */
    
}

