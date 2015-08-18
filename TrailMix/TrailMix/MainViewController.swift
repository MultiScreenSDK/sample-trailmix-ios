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
import MediaPlayer

class MainViewController: BaseVC,UITableViewDataSource, UITableViewDelegate {

    var videos = NSMutableOrderedSet()
    var userColor: String = String("#E91E63")
    var color: UIColor = UIColor()
    
    var currentTime = NSNumber()

    
    @IBOutlet weak var videosTableView: UITableView!
    
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var videoSlider: UISlider!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var videoInfoLabel: UILabel!
    

    @IBOutlet weak var videoPositionLabel: UILabel!
    
    @IBOutlet weak var videoDurationLabel: UILabel!
    
    @IBOutlet weak var deviceTypeImageView: UIImageView!
    
    
    @IBAction func resumePauseButtonPressed(sender: AnyObject) {
        if self.currentVideoState == "playing" {
            multiScreenManager.sendResumePause(false)
        } else if self.currentVideoState == "paused" {
            multiScreenManager.sendResumePause(true)
        } else {
            multiScreenManager.sendResumePause(true)
        }
    }
    
    
    @IBAction func videoSliderValueChanged(sender: AnyObject) {
        
    }
    var videoDuration: Int = 0
    
    var currentVideoState = String("unknown")

    
    var videoInfoViewRect: CGRect?
    var videosTableViewRect: CGRect?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currentTime = 0.0
        
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
        let url = NSURL(string: "http://multiscreen.samsung.com/examples/trailmix/trailers/library.json")
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissVC", name: multiScreenManager.dismissVCObserverIdentifier, object: nil)
        
        // Add an observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentStatus:", name: multiScreenManager.currentTrackStatusObserverIdentifier, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEnd:", name: multiScreenManager.videoEndObserverIdentifier, object: nil)
        
        
        let thumbImage = UIImage(named: "sliderhandle")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        
        UISlider.appearance().setThumbImage(thumbImage, forState: UIControlState.Normal)
        
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
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnTap = false
        setupView()
        if (idVideoSelectedInMobile != nil) {
            if let videoItem = videoItemFromId(idVideoSelectedInMobile!) {
                sendVideoToTV(videoItem)
                idVideoSelectedInMobile = nil
            }
        }
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
        let videoIem = (videos.objectAtIndex(indexPath.row) as! VideoItem)
        var imageURL: String? = videoIem.thumbnailURL
        
        cell.videoInfoLabel.text = videoIem.title
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
        
        
        
        if multiScreenManager.idVideoPlayigInTV != nil && videoIem.id == multiScreenManager.idVideoPlayigInTV!  {
            cell.contentView.alpha = 0.3
            cell.nowPlayingImageView.hidden = false
        }
        else {
            cell.contentView.alpha = 1.0
            cell.nowPlayingImageView.hidden = true
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoInfo = videos.objectAtIndex(indexPath.row) as! VideoItem
        idVideoSelectedInMobile = videoInfo.id
        if !multiScreenManager.isConnected {
            let url = videoInfo.fileURL
            let videoViewNavController = storyboard?.instantiateViewControllerWithIdentifier("VideoViewNavController") as! UINavigationController
            videoViewNavController.navigationBar.barTintColor = UIColor.clearColor()
            videoViewNavController.navigationBar.translucent = true
            
            let videoViewController = videoViewNavController.viewControllers[0] as! VideoViewController
            videoViewController.urlString = url
            videoViewController.videoTitle = videoInfo.title
            videoViewController.idVideoSelectedInMobile = videoInfo.id
            //self.navigationController?.pushViewController(videoViewController, animated: true)
            self.presentViewController(videoViewNavController, animated: true, completion: nil)
        } else if videoInfo.id != multiScreenManager.idVideoPlayigInTV {
            multiScreenManager.resetCurrentVideoData()
            sendVideoToTV(videoInfo)
            idVideoSelectedInMobile = nil
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setupView() {
        
        setLeftBarButtonText()
        
        if multiScreenManager.isConnected && multiScreenManager.idVideoPlayigInTV != nil{
            videoInfoView.hidden = false
            
            videosTableView.frame = CGRect(x: videoInfoView.frame.origin.x, y: videoInfoView.frame.origin.x + videoInfoView.frame.size.height+1, width: self.view.frame.width, height: self.view.frame.height - videoInfoView.frame.size.height)
            
    
            self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
            self.videoSlider.minimumValue = 0.0
            self.videoSlider.maximumValue = Float(videoDuration)
            self.videoSlider.value = Float(currentTime)
        } else {
            videosTableView.frame = CGRect(origin: videoInfoView.frame.origin, size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            
            videoInfoView.hidden = true
            self.navigationController?.navigationBar.barTintColor = color
            
        }
    }
    
    func serviceConnected() {
        setCastIcon()
        
        setLeftBarButtonText()
        
        videoSlider.hidden = true
        playPauseButton.hidden = true
        videoInfoLabel.hidden = true
        videoDurationLabel.hidden = true
        videoPositionLabel.hidden = true
        multiScreenManager.sendAppStateRequest()
    }
    
    /// dismisses the Queue/PlayList View Controller
    ///
    func dismissVC() {
        setLeftBarButtonText()
        self.dismissViewControllerAnimated(true, completion: nil)
        setupView()
        videosTableView.reloadData()
    }
    
    func setLeftBarButtonText() {
        if (self.navigationItem.leftBarButtonItem != nil) {
            if let label = self.navigationItem.leftBarButtonItem?.customView?.viewWithTag(100) as? UILabel {
                if let deviceTypeImageView = self.navigationItem.leftBarButtonItem?.customView?.viewWithTag(101) as? UIImageView {
                    if multiScreenManager.isConnected {
                        label.text = multiScreenManager.app.service.displayName
                        deviceTypeImageView.hidden = false
                        
                        label.frame = CGRectMake(deviceTypeImageView.frame.origin.x + deviceTypeImageView.frame.width + 5 , label.frame.origin.y, label.frame.width, label.frame.height)
                    } else {
                        label.text = "TrailMix"
                        deviceTypeImageView.hidden = true
                        
                        label.frame = CGRectMake(deviceTypeImageView.frame.origin.x, label.frame.origin.y, label.frame.width, label.frame.height)
                    }
                }
            }
            
        }
    }
    func updateCurrentStatus(notification: NSNotification) {
        let userInfo: [String:AnyObject] = notification.userInfo as! [String:AnyObject]
        if let currentStatusDict = (userInfo["userInfo"] as? [String:AnyObject]) {
            
            setupView()
            
            let currentVideoId = currentStatusDict["id"] as! String
            self.currentVideoState = currentStatusDict["state"] as! String
            
            if multiScreenManager.idVideoPlayigInTV != currentVideoId {
                multiScreenManager.idVideoPlayigInTV = currentStatusDict["id"] as? String
                videosTableView.reloadData()
            }
            multiScreenManager.idVideoPlayigInTV = currentStatusDict["id"] as? String
            
            currentTime = currentStatusDict["time"] as! NSNumber
            let fTime = Float(currentTime)
            videoDuration = currentStatusDict["duration"] as! Int
            self.videoSlider.minimumValue = 0.0
            self.videoSlider.maximumValue = Float(videoDuration)
            if !multiScreenManager.sliding {
                videoSlider.setValue(fTime, animated: true)
            }
            
            let (hoursVideoDuration,minuteVideoDuration,secsVideoDuration) = secondsToHoursMinutesSeconds(videoDuration)
            
            self.videoDurationLabel.text = String(format: "%02d:%02d:%02d", hoursVideoDuration,minuteVideoDuration,secsVideoDuration)
            
            let (hoursVideoPosition,minutesVideoPosition,secsVideoPosition) = secondsToHoursMinutesSeconds(Int(fTime))
            
            self.videoPositionLabel.text = String(format: "%02d:%02d:%02d", hoursVideoPosition,minutesVideoPosition,secsVideoPosition)
            
            videoInfoLabel.text = currentStatusDict["title"] as? String
            
            playPauseButton.setBackgroundImage(self.currentVideoState == "playing" ? UIImage(named: "ic_pause_dark"): UIImage(named: "ic_play_dark"), forState: UIControlState.Normal)
            
            videoInfoLabel.hidden = false
            videoSlider.hidden = false
            playPauseButton.hidden = false
            videoDurationLabel.hidden = false
            videoPositionLabel.hidden = false
        }
    }
    
    func videoEnd(notification: NSNotification) {
        let userInfo: [String:AnyObject] = notification.userInfo as! [String:AnyObject]
        if let currentStatusDict = (userInfo["userInfo"] as? [String:AnyObject]) {
            playPauseButton.setBackgroundImage(UIImage(named: "ic_replay_dark"), forState: UIControlState.Normal)
        }
    }
    
    
    func slidingStarted() {
        multiScreenManager.sliding = true
    }
    
    func slidingStopped() {
        multiScreenManager.sliding = false
        currentTime = videoSlider.value
        let fTime = Float(currentTime)
        let (hh,mm,ss) = secondsToHoursMinutesSeconds(Int(fTime))
        
        self.videoPositionLabel.text = String(format: "%02d:%02d:%02d", hh,mm,ss)
        multiScreenManager.sendSeek(Int(videoSlider.value))
    }
    
    func titleFromId(id: String) -> String {
        for elem in self.videos {
            let videoInfo = elem as! VideoItem
            if (videoInfo.id == id) {
                return videoInfo.title
            }
        }
        return "unknown video"
    }
    
    func videoItemFromId(id: String) -> VideoItem? {
        for elem in self.videos {
            let videoInfo = elem as! VideoItem
            if (videoInfo.id == id) {
                return videoInfo
            }
        }
        return nil
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func sendVideoToTV(videoInfo: VideoItem) {
        if multiScreenManager.isConnected {
            if multiScreenManager.idVideoPlayigInTV != nil && idVideoSelectedInMobile != multiScreenManager.idVideoPlayigInTV {
                let titleMsg: String = String("\(multiScreenManager.app.service.name) is Playing")
                let alertMsg: String = String("\(titleFromId(multiScreenManager.idVideoPlayigInTV!))")
                let alertView = UIAlertController(title: titleMsg, message: alertMsg, preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (alertAction) -> Void in
                    self.multiScreenManager.sendPlayVideo(videoInfo)
                    self.videosTableView.reloadData()
                }))
                alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presentViewController(alertView, animated: true, completion: nil)
            } else {
                multiScreenManager.sendPlayVideo(videoInfo)
                self.videosTableView.reloadData()
            }
        }
        
    }
}

