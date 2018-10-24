//
//  EnumError.swift
//  OnTheMap
//
//  Created by Bruno W on 26/07/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit
struct Errors {
    enum ErrorCode : Int{
        case The_Internet_connection_appears_to_be_offline = -1009
        case The_request_timed_out = -1001
        case No_error = 0
        case Response_statusCode_400_Bad_Request = 400
        case Response_statusCode_401_Unauthorized = 401
        case Response_statusCode_403_Forbidden = 403
        case Response_statusCode_404_Not_Found = 404
        case Response_statusCode_500_Internal_Server_Error = 500
        case Response_statusCode_no_2XX = 10000
        case Response_statusCode_error = 10001
        case No_data_or_unexpected_data_was_returned = 20000
        case Could_not_parse_the_data = 20001
        case Limit_of_requests_per_minute_was_exceeded = 20002
    }
    
    static func makeNSError(domain: String, code: Int, description: String) -> NSError{
        let info = [NSLocalizedDescriptionKey : description]
        return NSError(domain: domain, code: code, userInfo: info)
    }
    
    static func getDefaultDescription(errorCode : ErrorCode) -> String{
        switch errorCode {
        case .The_Internet_connection_appears_to_be_offline:
            return "The Internet connection appears to be offline!"
        case .The_request_timed_out:
            return "Time out!"
        case .No_error:
            return "Have no error!"
        case .Response_statusCode_400_Bad_Request:
            return "Invalid network request!"
        case .Response_statusCode_401_Unauthorized:
            return "Unauthorized!"
        case .Response_statusCode_403_Forbidden:
            return "Access unallowed!"
        case .Response_statusCode_404_Not_Found:
            return "Not found!"
        case .Response_statusCode_500_Internal_Server_Error:
            return "Internbal error!"
        case .Response_statusCode_no_2XX:
            return "Unsuccessful network request!"
        case .Response_statusCode_error:
            return "An response error has occurred!"
        case .No_data_or_unexpected_data_was_returned:
            return "No data or unexpected data was returned!"
        case .Could_not_parse_the_data:
            return "Could not parse the data!"
        case .Limit_of_requests_per_minute_was_exceeded:
            return "Limit of requests per minute was exceeded!"
        default:
            return "An unknown error has occurred"
        }
    }
    
    

    
    
}




