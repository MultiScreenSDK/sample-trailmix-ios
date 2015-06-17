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
    var appURL: String =  "http://s3-us-west-1.amazonaws.com/dev-multiscreen-examples/examples/trailmix/tv/index.html"
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
    
    /// Name of the observer identifier for remove track
    let removeTrackObserverIdentifier: String = "removeTrack"

    /// Name of the observer identifier for track start
    let trackStartObserverIdentifier: String = "trackStart"
    
    /// Name of the observer identifier for assign color
    let assignColorObserverIdentifier: String = "assignColor"
    
    let dismissQueueVCObserverIdentifier: String = "dismissQueueVC"
    
    
    /// Array of services/TVs
    var services = [Service]()
    

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
    func createApplication(service: Service, completionHandler: ((Bool!) -> Void)!){
        app = service.createApplication(NSURL(string: appURL)!, channelURI: channelId, args: ["cmd line params": "cmd line values"])
        app.delegate = self
        app.connectionTimeout = 5
        app.connect(["name": UIDevice.currentDevice().name], completionHandler: { (client, error) -> Void in
            if (error == nil){
                completionHandler(true)
            } else {
                completionHandler(false)
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
    
    /// Send UserColorRequest event to the connected Service
    ///
    func sendUserColorRequest() {
        if (isConnected){
            app.publish(event: "assignColorRequest", message: nil)
        }
    }
    
    /*
    /// Send AddTrack event to the the connected Service
    ///
    /// :param: MediaItem to be sent
    func sendAddTrack(var mediaItem: MediaItem){
        if (isConnected) {
            var addTrackDict: NSDictionary =
            [
                "id":mediaItem.id!,
                "artist":mediaItem.artist!,
                "album":mediaItem.name!,
                "title":mediaItem.title!,
                "duration":mediaItem.duration!,
                "file":mediaItem.fileURL!,
                "albumArt":mediaItem.albumArtURL!,
                "albumArtThumbnail":mediaItem.thumbnailURL!,
                "color":mediaItem.color!
            ]
            app.publish(event: "addTrack", message: addTrackDict, target: MessageTarget.All.rawValue)
        }
    }
    */
    
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
            var playVideoDict: NSDictionary =
            [
                "id":videoItem.id!,
                "title":videoItem.title!,
                "duration":videoItem.duration!,
                "file":videoItem.fileURL!,
            ]
            app.publish(event: "play", message: playVideoDict, target: MessageTarget.All.rawValue)
        }
    }
    
    /// Send NextTrack event to the the connected Service
    ///
    func sendNextTrack() {
        if isConnected {
            app.publish(event: "next", message: nil, target: MessageTarget.Broadcast.rawValue)
        }
    }
    
    
    func sendSeek(time: Int) {
        if isConnected {
            app.publish(event: "seek", message: time, target: MessageTarget.Broadcast.rawValue)
        }
    }
    
    /*
    /// Send RemoveTrack event to the the connected Service
    ///
    func sendRemoveTrack(var mediaItem: MediaItem) {
        if isConnected {
            app.publish(event: "removeTrack", message: mediaItem.id, target: MessageTarget.Broadcast.rawValue)
        }
    }
    */
    
    
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
        NSNotificationCenter.defaultCenter().postNotificationName(dismissQueueVCObserverIdentifier, object: self)
        
    }
    ///  ChannelDelegate
    ///  Called when the Channel receives a text message
    ///
    ///  :param: message: Text message received
    func onMessage(message: Message) {
        println(message.event)
        println(message.data)
        /*
        if message.event == "appState" {
            if let dict = message.data as? [String: AnyObject] {
                let queueMediaInfos =  (dict["playlist"]! as! [NSDictionary]).map {MediaItem(artist: $0["artist"] as! String, name: $0["album"] as! String, title: $0["title"] as! String, fileURL: $0["file"] as! String, albumArtURL: $0["albumArt"] as! String, thumbnailURL: $0["albumArtThumbnail"] as! String, id: $0["id"] as! String, duration: $0["duration"] as! Int, color: $0["color"] as! String)}
                
                NSNotificationCenter.defaultCenter().postNotificationName(refreshQueueObserverIdentifier, object: self, userInfo: ["userInfo" : queueMediaInfos])
                println(message.data)
                if let currentStatusDict = dict["currentStatus"] as? [String: AnyObject] {
                    if currentStatusDict.count > 0 {
                        println(currentStatusDict)
                        NSNotificationCenter.defaultCenter().postNotificationName(currentTrackStatusObserverIdentifier, object: self, userInfo: ["userInfo" : currentStatusDict])
                    }
                }
            }
        } else if message.event == "addTrack" {
            if let mediaItem = message.data as? [String:AnyObject] {
                let queueMediaItem = [MediaItem(artist: (mediaItem["artist"] as? String)!, name: (mediaItem["album"] as? String)!, title: (mediaItem["title"] as? String)!, fileURL: (mediaItem["file"] as? String)!, albumArtURL: (mediaItem["albumArt"] as? String)!, thumbnailURL: (mediaItem["albumArtThumbnail"] as? String)!, id: (mediaItem["id"] as? String)!, duration: (mediaItem["duration"] as? Int)!, color: (mediaItem["color"] as? String)!)]
                
                NSNotificationCenter.defaultCenter().postNotificationName(addTrackObserverIdentifier, object: self, userInfo: ["userInfo" : queueMediaItem])
            }
        } else */
        if message.event == "appState" {
            if let appStateDict = message.data as? [String:AnyObject] {
                if appStateDict.count > 0 {
                    if let currentStatusDict = appStateDict["currentStatus"] as? [String:AnyObject] {
                        if currentStatusDict.count > 0 {
                            println(currentStatusDict)
                            NSNotificationCenter.defaultCenter().postNotificationName(currentTrackStatusObserverIdentifier, object: self, userInfo: ["userInfo" : currentStatusDict])
                        }
                    }
                }
            }
        }
        if message.event == "videoStatus" {
            if let currentStatusDict = message.data as? [String:AnyObject] {
                if currentStatusDict.count > 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName(currentTrackStatusObserverIdentifier, object: self, userInfo: ["userInfo" : currentStatusDict])
                }
            }
        } else if message.event == "trackEnd" {
            sendAppStateRequest()
        } else if message.event == "removeTrack" {
            if let removeTrackId = message.data as? String {
                NSNotificationCenter.defaultCenter().postNotificationName(removeTrackObserverIdentifier, object: self, userInfo: ["userInfo" : removeTrackId])
            }
        } else if message.event == "trackStart" {
            if let trackStartId = message.data as? String {
                NSNotificationCenter.defaultCenter().postNotificationName(trackStartObserverIdentifier, object: self, userInfo: ["userInfo" : trackStartId])
            }
        } else if message.event == "assignColor" {
            if let assignColor = message.data as? String {
                NSNotificationCenter.defaultCenter().postNotificationName(assignColorObserverIdentifier, object: self, userInfo: ["userInfo" : assignColor])
            }
        }
    }
    
    func isSpeaker(service: Service) -> Bool {
        return service.type.endsWith("Speaker")
    }
}
