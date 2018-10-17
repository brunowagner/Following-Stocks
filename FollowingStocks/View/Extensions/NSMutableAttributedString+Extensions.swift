//
//  NSMutableAttributedString+Extensions.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/10/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//
// Code obtained from https://stackoverflow.com/questions/6501808/uilabel-with-text-of-two-different-colors

import Foundation
import UIKit
extension NSMutableAttributedString{
//    func setColorForText(_ textToFind: String?, with color: UIColor) {
//
//        let range:NSRange?
//        if let text = textToFind{
//            range = self.mutableString.range(of: text, options: .caseInsensitive)
//        }else{
//            range = NSMakeRange(0, self.length)
//        }
//        if range!.location != NSNotFound {
//            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range!)
//        }
//    }
    
    func setColorForRacionalNumber(positiveColor: UIColor, negativeColor: UIColor) {
        let range = NSMakeRange(0, self.length)
        let color : UIColor
        
        if self.mutableString.hasPrefix("-") || self.mutableString.hasPrefix("(-") {
            color = negativeColor
        } else {
            color = positiveColor
        }
        addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
}
