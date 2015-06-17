//
//  VideoItem.swift
//  TrailMix
//
//  Created by Prasath Thurgam on 6/11/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import Foundation
import UIKit

class VideoItem: NSObject {
    var title: String?
    var fileURL: String?
    var thumbnailURL: String?
    var duration: Int?
    var id: String?
    init(title: String, fileURL: String, thumbnailURL: String, duration: Int) {
        super.init()
        self.title = title
        self.fileURL = fileURL
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.id = generateId()
    }
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    func generateId() -> String {
        var k: Int = randomInt(1000000, max: 99999999)
        var s = String(k)
        println(s)
        return s
    }
}