//
//  AlphaVantageApiRequirements.swift
//  FollowingStocks
//
//  Created by Bruno W on 24/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class AlphaVantageApiRequirements: ApiRequirements {
    
    //https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=MSFT&apikey=1CSEQWZU1E835K1M
    
    func requestConfigToGET(urlRequest: inout NSMutableURLRequest) {
        urlRequest.httpMethod = "GET"
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
        return "www.alphavantage.co"
    }
    
    func getUrlPath() -> String {
        return "/query"
    }
    
}
