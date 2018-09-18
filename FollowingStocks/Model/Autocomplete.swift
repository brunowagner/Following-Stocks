//
//  Autocomplete.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class Autocomplete {
    
    //http://autoc.finance.yahoo.com/autoc?query=Brasileiro&region=EU&lang=en-GB
    
    func find(query: String, region : String, lang: String) -> Dictionary {
        
        let parameters: [String : AnyObject] = [
            "query" : query as AnyObject,
            "region" : region as AnyObject,
            "lang" : lang as AnyObject
        ]
        
        
        HTTPTools.taskForGETMethod(<#T##method: String##String#>, parameters: parameters, apiRequirements: <#T##ApiRequirements#>, completionHandlerForGET: <#T##(AnyObject?, NSError?) -> Void#>)
    }
}
