//
//  Autocomplete.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class AutoCompleteCliente {
    
    static let sharedInstance = AutoCompleteCliente()
    
    static func requestPaper(query : String, completion: @escaping (_ success: Bool , _ data: [String : AnyObject]? ,_ error: NSError? ) -> Void) {
        
        let parameters = [
            Constants.AutoComplete.ParameterKey.query : query,
            Constants.AutoComplete.ParameterKey.region: Constants.AutoComplete.ParameterValue.region1,
            Constants.AutoComplete.ParameterKey.lang : Constants.AutoComplete.ParameterValue.langEng
            ] as [String: AnyObject]
        
        let _ = HTTPTools.taskForGETMethod("", parameters: parameters, apiRequirements: AutocompleteApiRequirements()) { (data, error) in
            
            guard error == nil else{
                completion(false, nil, error)
                fatalError("An error accurred to request data : " + (error?.localizedDescription)!)
            }
            
            if let data = data as? [String : AnyObject] {
                completion(true, data, nil)
            } else {
                completion(false, nil, Errors.makeNSError(domain: "requestPaper", code: Errors.ErrorCode.Could_not_parse_the_data.rawValue, description: Errors.getDefaultDescription(errorCode: .Could_not_parse_the_data)))
            }
            
        }
    }
}
