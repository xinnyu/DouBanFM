//
//  XYCircleAndRotationImageView.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/7.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import UIKit


@IBDesignable
class XYCircleAndRotationImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    let rotation = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
    let CASrotation = CABasicAnimation(keyPath: "transform.rotation")
    
    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    
    // MARK: - POPAnimation相关方法
    
    func startRotation(){
        
        //rotation.fromValue = 0
        rotation?.toValue = M_PI * 2
        rotation?.duration = 10
        rotation?.repeatForever = true
        rotation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        
        
        self.layer.pop_add(rotation, forKey: "旋转")
    }
    
    func stopRotation(){
        
        rotation?.isPaused = true
        
    }
    
    func resumeRotation(){
        rotation?.isPaused = false
    }
    
    // MARK: - CoreAnimation相关方法
    
    func CAStartRotation(){
        
        CASrotation.duration = 2
        CASrotation.fromValue = 0
        CASrotation.toValue = M_PI * 2
        CASrotation.repeatCount = MAXFLOAT
        
        self.layer.add(CASrotation, forKey: "rotation10")
        
    }
    
    func CAStopRotation(){
        // 取出当前的时间点，就是暂停的时间点
        let pauseTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
        // 将速度设为0
        self.layer.speed = 0.0
        // 设定时间偏移量，让动画定格在那个时间点
        self.layer.timeOffset = pauseTime
    }
    
    func CAResumeRotation(){
        // 获取暂停的时间
        let pauseTime = self.layer.timeOffset
        self.layer.speed = 1.0
        self.layer.timeOffset = 0
        self.layer.beginTime = 0
        let sincePauseTime = self.layer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        self.layer.beginTime = sincePauseTime
    }
    
}
