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
    var title: String
    var fileURL: String
    var thumbnailURL: String
    var duration: Int
    var id: String
    var year: String
    var cast: String
    var type: String
    
    init(title: String, fileURL: String, thumbnailURL: String, duration: Int, id: String, year: String, cast: String, type: String) {
        self.title = title
        self.fileURL = fileURL
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.id = id
        self.year = year
        self.cast = cast
        self.type = type
    }
}