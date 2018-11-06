//
//  MoneyTextFieldDelegate.swift
//  Text Field Challenge Apps
//
//  Created by Bruno W on 18/05/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit

class MoneyTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    let prefix : String
    
    init(prefix : String = "$") {
        self.prefix = prefix
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var result : Bool = true
        if string.count == 0{
            result = deleting(textField, range, string)
        }else{
            result = inserting(textField, string)
        }
        
        return result
    }
    
    func inserting(_ textField: UITextField, _ string: String) -> Bool{
        let texto = textField.text!
        let atual = "\(texto)\(string)"
        var actualValue : Double = Double(atual.replacingOccurrences(of: prefix, with: ""))!
        
        actualValue *= 10
        
        let novo = String(format: "%.2f", actualValue)

        textField.text = "\(prefix)\(novo)"
        
        return false
    }
    
    func deleting(_ textField: UITextField, _ range: NSRange,_ string: String) -> Bool{
        var nextText = textField.text! as NSString
        nextText = nextText.replacingCharacters(in: range, with: string) as NSString
        
        var actualValue : Double = Double(nextText.replacingOccurrences(of: prefix, with: ""))!
        
        actualValue /= 10
        
        let novo = String(format: "%.2f", actualValue)

        textField.text = "\(prefix)\(novo)"

        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text!.isEmpty{
            textField.text = "\(prefix)0.00"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
