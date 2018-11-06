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
        
        //function=GLOBAL_QUOTE&symbol=MSFT&apikey=1CSEQWZU1E835K1M
        //TO DO: Colocar as mensagens abaixo em uma estrutura de constantes.
        /*  quando excede 5 requests por minuto
         {
         "Information": "Thank you for using Alpha Vantage! Please visit https://www.alphavantage.co/premium/ if you would like to have a higher API call volume."
         }
         */
        
        /*  quando a apikey é inválida ou inexistente
         {
         "Error Message" = "the parameter apikey is invalid or missing. Please claim your free API key on (https://www.alphavantage.co/support/#api-key). It should take less than 20 seconds, and is free permanently.";
         }
         */
        
        /*  quando a função não existe
         {
         "Error Message": "This API function (GLOBAL_QUOT) does not exist."
         }
         */
        
        let parameters : [String:AnyObject] = [
            "function" : "GLOBAL_QUOTE" as AnyObject,
            "symbol": symbol as AnyObject,
            "apikey": "1CSEQWZU1E835K1M" as AnyObject
        ]
        
        let _ = HTTPTools.taskForGETMethod("", parameters: parameters, apiRequirements: AlphaVantageApiRequirements()) { (data, error) in
            
            guard error == nil else{
                completion(false,nil,error)
                return
            }
            
            print(data!)
            
            guard let response = data as? [String : AnyObject] else {
                return completion(true, nil, Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.No_data_or_unexpected_data_was_returned.rawValue, description: "Do not have quote to paper searched!"))
            }
            
            if let errorMessage = response["Information"] as? String,  errorMessage.contains("if you would like to have a higher API call volume") {
                return completion(false,nil,Errors.makeNSError(domain: "Request Quote", code: Errors.ErrorCode.Limit_of_requests_per_minute_was_exceeded.rawValue, description: errorMessage))
            }
            
            if let errorMessage = response["Error Message"] as? String {
                print(errorMessage)
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
