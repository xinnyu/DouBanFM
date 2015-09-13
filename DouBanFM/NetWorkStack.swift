//
//  NetWorkStack.swift
//  DouBanFM
//
//  Created by 潘新宇 on 15/9/6.
//  Copyright © 2015年 潘新宇. All rights reserved.
//

import Foundation
import Alamofire

class NetWorkStark:NSObject{
    
    var delegate:NetWorkStarkDelegate?
    var alert:UIAlertController?
    
    
    func getResult(url:String){
        
        Alamofire.request(.GET, url).response { (_, _, data, err) -> Void in
            if err == nil{
                self.delegate?.didGetResult(data!)
            }else{
                print("网络请求错误：" + err.debugDescription)
            }
        }
    }
    
//    func getData(url:String) -> NSData{
//        Alamofire.request(.GET, url).response { (_, _, data, err) -> Void in
//            if err == nil{
//                return data
//            }
//        }
//    }
}


protocol NetWorkStarkDelegate{
    func didGetResult(data:NSData)
}