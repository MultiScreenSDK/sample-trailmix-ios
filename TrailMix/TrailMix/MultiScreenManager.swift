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
import SystemConfiguration
import MSF

/// A MultiScreenManager represents an instance of MultiScreenFramework

/// Use this class to search for near services, connect to a service and send photo to a service
class MultiScreenManager: NSObject, ServiceSearchDelegate, ChannelDelegate {
    
    var queueMedias = NSMutableOrderedSet()
    
    /// Application url
    var appURL: String =  "http://multiscreen.samsung.com/examples/trailmix/tv/index.html"
    /// Application Channel
    //var channelId: String = "com.samsung.multiscreen.photos"
    var channelId: String = "com.samsung.trailmix"
    /// Application instance
    var app: Application!
    /// Search service instance
    let search = Service.search()
    
    /// Name of the observer identifier for services found
    let servicesChangedObserverIdentifier: String = "servicesChanged"
    
    /// Name of the observer identifier for service connected
    let serviceConnectedObserverIdentifier: String = "serviceConnected"
    
    /// Name of the observer identifier for refresh queue
    let refreshQueueObserverIdentifier: String = "refreshQueue"
    
    let addTrackObserverIdentifier: String = "trackAdded"
    
    /// Name of the observer identifier for current track status
    let currentTrackStatusObserverIdentifier: String = "currentTrackStatus"
    
    /// Name of the observer identifier for video end
    let videoEndObserverIdentifier: String = "videoEnd"
    
    /// Name of the observer identifier for remove track
    let removeTrackObserverIdentifier: String = "removeTrack"
    
    /// Name of the observer identifier for assign color
    let assignColorObserverIdentifier: String = "assignColor"
    
    let dismissVCObserverIdentifier: String = "dismissVC"
    
    
    /// Array of services/TVs
    var services = [Service]()
    

    var sliding: Bool = false
    
    /// returns the status if the channel/app is connected
    var isConnected: Bool {
        get {
           return app != nil && app!.isConnected;
        }
    }
    
    /// returns the currently connected service
    var currentService: Service {
        get {
            return app.service
        }
    }
    
    var idVideoPlayigInTV: String? = String()
    var videoState: String? = String()
    var videoTime: NSTimeInterval? = NSTimeInterval()
    var paused: Bool = Bool()
    
    /// MultiScreenManager shared instance used as singleton
    class var sharedInstance: MultiScreenManager {
        struct Static {
            static var instance: MultiScreenManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = MultiScreenManager()
        }
        
        return Static.instance!
    }
    
    override init() {
        super.init()
        search.delegate = self
        idVideoPlayigInTV = nil
        resetCurrentVideoData()
    }
    
    func resetCurrentVideoData() {
        
        videoState = nil
        videoTime = 0
        paused = false
    }
    
    /// Post a notification to the NSNotificationCenter
    /// this notification is used to update the cast icon
    func postNotification(){
        NSNotificationCenter.defaultCenter().postNotificationName(servicesChangedObserverIdentifier, object: self)
    }
    
    /// Start the search for services/TVs
    func startSearching(){
        search.start()
    }
    
    /// Stop the search for services/TVs
    func stopSearching(){
        search.stop()
        services.removeAll(keepCapacity: false)
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    /// onServiceLost delegate method
    func onServiceLost(service: Service) {
        removeObject(&services, object: service)
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    /// onServiceFound delegate method
    func onServiceFound(service: Service) {
        services.append(service)
        /// post a notification to the NSNotificationCenter
        postNotification()
    }
    
    func removeObject<T: Equatable>(inout arr: Array<T>, object: T) -> T? {
        if let found = find(arr, object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }
    
    
    /// Return all services availables but not currently connected
    ///
    /// :return: Array of Services
    func servicesCopy() -> [Service]{
        
        var servicesArray = [Service]()
        for (value) in services {
            servicesArray.append(value)
        }
        return servicesArray
        
    }
    
   
    /// Connect to an Application
    ///
    /// :param: selected service
    /// :param: completionHandler The callback handler,  return true or false
    func createApplication(service: Service, completionHandler: ((Bool!,error: NSError!) -> Void)!){
        app = service.createApplication(NSURL(string: appURL)!, channelURI: channelId, args: ["cmd line params": "cmd line values"])
        app.delegate = self
        app.connectionTimeout = 5
        app.connect(["name": UIDevice.currentDevice().name], completionHandler: { (client, error) -> Void in
            if (error == nil){
                completionHandler(true,error: error)
            } else {
                completionHandler(false,error: error)
            }
        })
    }
    
    /// Close the current connected application
    ///
    /// :param: completionHandler The callback handler,  return true or false
    func closeApplication(completionHandler: ((Bool!) -> Void)!){
        app.disconnect(leaveHostRunning: true, completionHandler: { (channel, error) -> Void in
            if (error == nil){
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }
    
    /// Send AppStateRequest event to the connected Service
    ///
    func sendAppStateRequest() {
        if (isConnected){
            app.publish(event: "appStateRequest", message: nil)
        }
    }
    
    
    /// Send PlayPause event to the the connected Service
    ///
    /// :param: true - play, false - pause
    func sendResumePause(play: Bool) {
        if isConnected {
            app.publish(event: play ? "resume":"pause", message: nil, target: MessageTarget.Broadcast.rawValue)
        }
    }
    
    func sendPlayVideo(videoItem: VideoItem) {
        if isConnected {
            var playVideoDict: Dictionary<String,AnyObject> =
            [
                "id":videoItem.id,
                "title":videoItem.title,
                "duration":videoItem.duration,
                "file":videoItem.fileURL
            ]
            if paused == true {
                playVideoDict["state"] = "paused"
            }
            if videoTime > 0 {
                playVideoDict["time"] = videoTime
            }
            app.publish(event: "play", message: playVideoDict, target: MessageTarget.All.rawValue)
            idVideoPlayigInTV = videoItem.id
        }
    }
    

    
    func sendSeek(time: Int) {
        if isConnected {
            app.publish(event: "seek", message: time, target: MessageTarget.Broadcast.rawValue)
        }
    }
    
    
    //MARK: - ChannelDelegate -
    
    ///  Called when a Channel Error is fired
    ///
    ///  :param: error: The error
    func onError(error: NSError) {
        println(error.localizedDescription)
    }
    
    ///  Called when the Channel is connected
    ///
    ///  :param: client: The Client that just connected to the Channel
    ///
    ///  :param: error: An error info if any
    func onConnect(client: ChannelClient?, error: NSError?) {
        if (error == nil) {
            stopSearching()
            /// post a notification to the NSNotificationCenter
            postNotification()
        }
    }
    
    ///  Called when the Channel is disconnected
    ///
    ///  :param: client The Client that just disconnected from the Channel
    ///
    ///  :param: error: An error info if any
    func onDisconnect(client: ChannelClient?, error: NSError?) {
        startSearching()
        idVideoPlayigInTV = nil
        NSNotificationCenter.defaultCenter().postNotificationName(dismissVCObserverIdentifier, object: self)
        
    }
    ///  ChannelDelegate
    ///  Called when the Channel receives a text message
    ///
    ///  :param: message: Text message received
    func onMessage(message: Message) {
        if message.event == "appState" {
            if let appStateDict = message.data as? [String:AnyObject] {
                if appStateDict.count > 0 {
                    if let currentStatusDict = appStateDict["currentStatus"] as? [String:AnyObject] {
                        if currentStatusDict.count > 0 {
                            NSNotificationCenter.defaultCenter().postNotificationName(currentTrackStatusObserverIdentifier, object: self, userInfo: ["userInfo" : currentStatusDict])
                        }
                    }
                }
            }
        }
        if message.event == "videoStatus" {
            if let currentStatusDict = message.data as? [String:AnyObject] {
                if currentStatusDict.count > 0  && sliding != true {
                    NSNotificationCenter.defaultCenter().postNotificationName(currentTrackStatusObserverIdentifier, object: self, userInfo: ["userInfo" : currentStatusDict])
                }
            }
        } else if message.event == "videoEnd" {
            idVideoPlayigInTV = nil
            //sendAppStateRequest()
            if let currentStatusDict = message.data as? [String:AnyObject] {
                if currentStatusDict.count > 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName(videoEndObserverIdentifier, object: self, userInfo: ["userInfo" : currentStatusDict])
                }
            }
        } else if message.event == "videoStart" {
            idVideoPlayigInTV = message.data as? String
        }
    }
    
    func isSpeaker(service: Service) -> Bool {
        return service.type.endsWith("Speaker")
    }
}
