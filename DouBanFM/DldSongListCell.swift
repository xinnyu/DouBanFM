//
//  DldSongListCell.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/11.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class DldSongListCell: UITableViewCell {

    @IBOutlet var numLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
