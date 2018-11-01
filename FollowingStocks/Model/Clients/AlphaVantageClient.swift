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
    
    private static let apiKeys : [String] = [
        "1CSEQWZU1E835K1M"//,
//        "YW2OFU8R4SSYOONV",
//        "UD7R3VMN5OYV0EUS",
//        "CJIAZWCX7CE2LA75",
//        "7ZW0W72P6TRGA77D",
//        "FDMIRQ5VMIOO8ZK9"
    ]
    
    private static var index = -1

    
    static func  requestQuote (symbol : String, completion: @escaping (_ success: Bool , _ quote: GlobalQuote? ,_ error: NSError? ) -> Void) {
        
        //function=GLOBAL_QUOTE&symbol=MSFT&apikey=1CSEQWZU1E835K1M
        
        /*  quando excede 5 requests por minuto
         {
            "Information": "Thank you for using Alpha Vantage! Please visit https://www.alphavantage.co/premium/ if you would like to have a higher API call volume."
        }
         
         {
         Note = "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day. Please visit https://www.alphavantage.co/premium/ if you would like to target a higher API call frequency.";
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
            
            if let errorMessage = response["Note"] as? String,  errorMessage.contains("if you would like to target a higher API call frequency") {
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
 
    private static func getApiKey() -> String {
        index = index < 0 ? apiKeys.count : index
        let numberOfKeys = apiKeys.count
        if numberOfKeys == 0 { return ""}
        let key = apiKeys[numberOfKeys - index]
        index -= 1
        return key
    }
}

//MARK: Structs
extension AlphaVantageClient{
    // Decidi deixar em arquivo separado (QueteStruct)
//    struct GlobalQuote {
//
//        let symbol: String //"2260.SR",
//        let open: Double//"16.5200",
//        let high: Double//"16.5400",
//        let low: Double//"16.2800",
//        let price: Double//"16.5200",
//        let volume: Int32 //"1736234",
//        let latestTradingDay: String //Date//"2018-09-13",
//        let previousClose: Double//"16.7000",
//        let change: Double//"-0.1800",
//        let changePercent: String//"-1.0778%"
//
//        init?(dicGlobalQuote: [String: AnyObject]) {
//            guard let quote = dicGlobalQuote["Global Quote"] as? [String : AnyObject] else {
//                print("Não foi encontrado 'Global Quote nos dados baixados.'")
//                return nil
//            }
//            if quote.count == 0 { return nil}
//            
//            self.symbol = quote["01. symbol"] as! String
//            self.open = (quote["02. open"] as! NSString).doubleValue
//            self.high = (quote["03. high"] as! NSString).doubleValue
//            self.low = (quote["04. low"] as! NSString).doubleValue
//            self.price = (quote["05. price"] as! NSString).doubleValue
//            self.volume = (quote["06. volume"] as! NSString).intValue
//            self.latestTradingDay = (quote["07. latest trading day"] as! String)
//            self.previousClose = (quote["08. previous close"] as! NSString).doubleValue
//            self.change = (quote["09. change"] as! NSString).doubleValue
//            self.changePercent = quote["10. change percent"] as! String
//        }
//    }
}
