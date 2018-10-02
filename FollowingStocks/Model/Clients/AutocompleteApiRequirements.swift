//
//  AutocompleteApiRequirements.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class AutocompleteApiRequirements: ApiRequirements {
    
    //http://autoc.finance.yahoo.com/autoc?query=Brasileiro&region=EU&lang=en-GB
    
    func requestConfigToGET(urlRequest: inout NSMutableURLRequest) {
        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.addValue("pt-br", forHTTPHeaderField: "Accept-Language")
    }
    
    func requestConfigToPOST(urlRequest: inout NSMutableURLRequest, jsonBody: String?) {
        urlRequest.httpMethod = "POST"
    }
    
    func requestConfigToPUT(urlRequest: inout NSMutableURLRequest, jsonBody: String?) {
        urlRequest.httpMethod = "PUT"
    }
    
    func requestConfigToDELET(urlRequest: inout NSMutableURLRequest) {
        urlRequest.httpMethod = "DELETE"
    }
    
    func getValidData(data: Data) -> Data {
        return data
    }
    
    func getUrlScheme() -> String {
        return "https"
    }
    
    func getUrlHost() -> String {
        return "autoc.finance.yahoo.com"
    }
    
    func getUrlPath() -> String {
        return "/autoc"
    }
}
