//
//  Alerts.swift
//  OnTheMap
//
//  Created by Bruno W on 26/07/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit
struct Alerts {
    
    enum  toastSpeed : Double{
        //in seconds
        case short = 0.5
        case medium = 1
        case long = 2
    }
    
    // Alert Standart
    static func message (view: UIViewController ,title:String?, message:String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.isSpringLoaded = true
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        view.present(alert, animated: true, completion: nil)
    }
    
    // Alert with buttons yes and no
    static func yesNo (view: UIViewController , title:String?, message:String?, completionHander: @escaping (_ yes: Bool) ->Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            completionHander(true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            completionHander(false)
        }))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    // Alert disappear it self
    static func toast(view: UIViewController, message: String, speed: toastSpeed, completion: (()->Void)?){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        
        view.present(alert, animated: true) {
            usleep(useconds_t(speed.rawValue * 1000000))
            view.dismiss(animated: true, completion: completion)
        }
    }
}
