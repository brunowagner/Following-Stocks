//
//  Utilities.swift
//  FollowingStocks
//
//  Created by Bruno W on 26/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
struct Utilities {
    struct Convert {
        ///Converte tipo String em Tipo Date. Ex: stringToDate("2018-09-11", "yyyy-mm-dd")
        static func stringToDate(_ stringDate: String, dateFormat: String) -> Date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat //"yyyy-mm-dd" //Your date format
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            guard let date = dateFormatter.date(from: stringDate) else {//according to date format your date string
                fatalError("Date can not be converted!")
            }
            return date
        }
        
        static func dateToString (date : Date, dateFormat : String = "yyyy-MM-dd") -> String{
            let date = NSDate() // Get Todays Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let stringDate: String = dateFormatter.string(from: date as Date)
            return stringDate
        }
    }
}
