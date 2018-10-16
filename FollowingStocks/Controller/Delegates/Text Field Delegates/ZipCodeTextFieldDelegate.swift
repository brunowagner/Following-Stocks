//
//  ZipCodeDelegate.swift
//  Text Field Challenge Apps
//
//  Created by Bruno W on 18/05/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit

class ZipCodeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    let charactersLimit=5

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var nextString = textField.text! as NSString
        nextString = nextString.replacingCharacters(in: range, with: string) as NSString
        
        guard nextString.length <= self.charactersLimit else {
            return false
        }
        
        return true
    }
    
}
