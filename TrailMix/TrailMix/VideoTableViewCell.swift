//
//  VideoTableViewCell.swift
//  TrailMix
//
//  Created by Prasath Thurgam on 6/11/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    
    @IBOutlet weak var videoInfoLabelImageView: UIImageView!
    @IBOutlet weak var videoInfoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
