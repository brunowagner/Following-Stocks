//
//  AlphaVantageClient.swift
//  FollowingStocks
//
//  Created by Bruno W on 24/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class AlphaVantageClient {
    
    static let sharedInstance = AlphaVantageClient()
    
    static func  requestQuote (symbol : String, completion: @escaping (_ success: Bool , _ quote: GlobalQuote? ,_ error: NSError? ) -> Void) {

        let parameters : [String:AnyObject] = [
            Constants.AlphaVantageClient.ParameterKey.function : Constants.AlphaVantageClient.ParameterValue.functionGlobalQuote as AnyObject,
            Constants.AlphaVantageClient.ParameterKey.symbol :symbol as AnyObject,
            Constants.AlphaVantageClient.ParameterKey.apikey : Constants.AlphaVantageClient.ParameterValue.apiKey as AnyObject
        ]
        
        let _ = HTTPTools.taskForGETMethod("", parameters: parameters, apiRequirements: AlphaVantageApiRequirements()) { (data, error) in
            
            guard error == nil else{
                completion(false,nil,error)
                return
            }
            
            guard let response = data as? [String : AnyObject] else {
                return completion(true, nil, Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.No_data_or_unexpected_data_was_returned.rawValue, description: "Do not have quote to paper searched!"))
            }
            
            if let errorMessage = response[Constants.AlphaVantageClient.FaultKey.note] as? String,  errorMessage.contains("premium") {
                return completion(false,nil,Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.Limit_of_requests_per_minute_was_exceeded.rawValue, description: errorMessage))
            }
            
            if let errorMessage = response[Constants.AlphaVantageClient.FaultKey.information] as? String,  errorMessage.contains("premium") {
                return completion(false,nil,Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.Limit_of_requests_per_minute_was_exceeded.rawValue, description: errorMessage))
            }
            
            if let errorMessage = response[Constants.AlphaVantageClient.FaultKey.errorMessage] as? String {
                return completion(false,nil,Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.Response_statusCode_error.rawValue, description: errorMessage))
            }
            
            if let result = GlobalQuote(dicGlobalQuote: response){
                completion(true, result, nil)
            } else {
                completion(true, nil, Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.No_data_or_unexpected_data_was_returned.rawValue, description: "Do not have quote to paper searched!"))
            }
        }
    }
}
