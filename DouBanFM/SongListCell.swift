//
//  SongListCell.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/7.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class SongListCell: UITableViewCell {

    @IBOutlet var artistNameLabel: UILabel!
    
    @IBOutlet var songImage: UIImageView!
    
    @IBOutlet var dldBtn: UIButton!
    
    @IBOutlet var songNameLabel: UILabel!

    @IBOutlet var playMask: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func dldBtnClick(_ sender: UIButton) {
        print(sender.tag)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state UIColor(red:0.94, green:0.94, blue:0.96, alpha:1)
        
    }
    
    
//    override func drawRect(rect: CGRect) {
//        let context:CGContextRef = UIGraphicsGetCurrentContext()!
//        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
//        CGContextFillRect(context, rect)
//        CGContextSetStrokeColorWithColor(context, UIColor(red:0.9, green:0.9, blue:0.92, alpha:1).CGColor)
//        CGContextStrokeRect(context, CGRectMake(60, -1, rect.size.width - 60, 1))
//    }


}
