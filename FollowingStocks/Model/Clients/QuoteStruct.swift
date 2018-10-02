//
//  QuoteStruct.swift
//  FollowingStocks
//
//  Created by Bruno W on 26/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
struct GlobalQuote {
    
    let symbol: String //"2260.SR",
    let open: Double//"16.5200",
    let high: Double//"16.5400",
    let low: Double//"16.2800",
    let price: Double//"16.5200",
    let volume: Int32 //"1736234",
    let latestTradingDay: String //Date//"2018-09-13",
    let previousClose: Double//"16.7000",
    let change: Double//"-0.1800",
    let changePercent: String//"-1.0778%"
    
    init?(dicGlobalQuote: [String: AnyObject]) {
        guard let quote = dicGlobalQuote["Global Quote"] as? [String : AnyObject] else {
            print("Não foi encontrado 'Global Quote nos dados baixados.'")
            return nil
        }
        if quote.count == 0 { return nil}
        
        self.symbol = quote["01. symbol"] as! String
        self.open = (quote["02. open"] as! NSString).doubleValue
        self.high = (quote["03. high"] as! NSString).doubleValue
        self.low = (quote["04. low"] as! NSString).doubleValue
        self.price = (quote["05. price"] as! NSString).doubleValue
        self.volume = (quote["06. volume"] as! NSString).intValue
        self.latestTradingDay = (quote["07. latest trading day"] as! String)
        self.previousClose = (quote["08. previous close"] as! NSString).doubleValue
        self.change = (quote["09. change"] as! NSString).doubleValue
        self.changePercent = quote["10. change percent"] as! String
    }
}
