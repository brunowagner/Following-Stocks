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
            print("Not finded 'Global Quote' ín download data.")
            return nil
        }
        if quote.count == 0 { return nil}
        
        self.symbol = quote[Constants.AlphaVantageClient.ResponseKey.symbol] as! String
        self.open = (quote[Constants.AlphaVantageClient.ResponseKey.open] as! NSString).doubleValue
        self.high = (quote[Constants.AlphaVantageClient.ResponseKey.high] as! NSString).doubleValue
        self.low = (quote[Constants.AlphaVantageClient.ResponseKey.low] as! NSString).doubleValue
        self.price = (quote[Constants.AlphaVantageClient.ResponseKey.price] as! NSString).doubleValue
        self.volume = (quote[Constants.AlphaVantageClient.ResponseKey.volume] as! NSString).intValue
        self.latestTradingDay = (quote[Constants.AlphaVantageClient.ResponseKey.latestTradingDay] as! String)
        self.previousClose = (quote[Constants.AlphaVantageClient.ResponseKey.previousClose] as! NSString).doubleValue
        self.change = (quote[Constants.AlphaVantageClient.ResponseKey.change] as! NSString).doubleValue
        self.changePercent = quote[Constants.AlphaVantageClient.ResponseKey.changePercent] as! String
    }
    
    init(quote: Quote) {
        self.symbol = (quote.paper?.symbol)!
        self.open = quote.open
        self.high = quote.high
        self.low = quote.low
        self.price = quote.price
        self.volume = quote.volume
        self.latestTradingDay = Utilities.Convert.dateToString(date: quote.latest!)
        self.previousClose = quote.previousClose
        self.change = quote.change
        self.changePercent = quote.changePercent!
    }
}
