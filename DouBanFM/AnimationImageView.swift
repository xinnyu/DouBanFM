//
//  AnimationImageView.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/9.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit

class AnimationImageView{

    
    private static var __once: () = { () -> Void in
            singleTon.animationImageView = UIImageView(image: UIImage(named: "cm2_top_icn_playing_prs")!)
            singleTon.animationImageView.animationImages = [UIImage(named: "cm2_top_icn_playing_prs")!,
                UIImage(named: "cm2_top_icn_playing2_prs")!,
                UIImage(named: "cm2_top_icn_playing3_prs")!,
                UIImage(named: "cm2_top_icn_playing4_prs")!,
                UIImage(named: "cm2_top_icn_playing5_prs")!,
                UIImage(named: "cm2_top_icn_playing6_prs")!]
            singleTon.animationImageView.animationDuration = 1.5
            
            
        }()

    
    class func shareAnimationImageView() -> UIImageView{
        _ = AnimationImageView.__once
        return singleTon.animationImageView
    }
    
    struct singleTon {
        static var animationImageView:UIImageView!
        static var once_t:Int = 0
    }
}
