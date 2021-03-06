//
//  Constants.swift
//  FollowingStocks
//
//  Created by Bruno W on 06/11/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
struct Constants {
    //MARK: -
    struct SegueId{
        static let searchToDetail2 = "SearchToDetail2"
        static let unwindToTradeViewController = "unwindToTradeViewController"
        static let tradeToSearch = "TradeToSearch"
        static let unwindToDetail = "unwindToDetail"
        static let followingToDetail2 = "FollowingToDetail2"
        static let portfolioToDetail2 = "PortfolioToDetail2"
        static let detailToTrade = "DetailToTrade"
    }
    //MARK: -
    struct ViewControllerId{
        static let tradeViewController = "TradeViewController"
        static let detailViewController2 = "DetailViewController2"
    }
    //MARK: -
    struct ReusableCell{
        static let portfolioCell = "PortfolioCell"
        static let followingCell = "FollowingCell"
        static let searchCell = "SearchCell"
    }
    //MARK: -
    struct ImageName {
        static let following = "baseline_my_location_black_24pt"
        static let unfollowing = "baseline_location_disabled_black_24pt"
        
    }
    //MARK: -
    struct CollorName {
        static let darkGreen = "DarkGreen"
    }
    //MARK: -
    struct PredicateFormat {
        static let isFollowing = "isFollowed == %@"
        static let isPortfolio = "isPortfolio == %@"
        static let symbol = "symbol == %@"
    }
    //MARK: -
    struct Predicate {
        static let isFollowing : NSPredicate = NSPredicate(format: "isFollowed == %@", NSNumber(value: true))
        static let isPortfolio : NSPredicate = NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))
    }
    //MARK: -
    struct AutoComplete {
        struct ResponseKey {
            static let symbol = "symbol"
            static let name = "name"
            static let exch = "exch"
            static let type = "type"
            static let exchDisp = "exchDisp"
            static let typeDisp = "typeDisp"
        }
        
        struct ParameterValue {
            static let langEng = "eng"
            static let region1 = "1"
        }
        
        struct ParameterKey {
            static let query = "query"
            static let region = "region"
            static let lang = "lang"
        }
    }
    //MARK: -
    struct AlphaVantageClient {
        struct FaultKey{
            static let note = "Note"
            static let information = "Information"
            static let errorMessage = "Error Message"
        }
        
        struct FaultValue{
            static let informationExceededLimit1 = "Thank you for using Alpha Vantage! Please visit https://www.alphavantage.co/premium/ if you would like to have a higher API call volume."
            static let informationExceededLimit2 = "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day. Please visit https://www.alphavantage.co/premium/ if you would like to target a higher API call frequency."
            static let errorMessageApi = "the parameter apikey is invalid or missing. Please claim your free API key on (https://www.alphavantage.co/support/#api-key). It should take less than 20 seconds, and is free permanently."
            static let errorMessageFunction = "This API function (GLOBAL_QUOT) does not exist."
        }
        
        struct ParameterValue{
            static let functionGlobalQuote = "GLOBAL_QUOTE"
            static let apiKey = "1CSEQWZU1E835K1M"
        }
        
        struct ParameterKey{
            static let function = "function"
            static let symbol = "symbol"
            static let apikey = "apikey"
        }
        
        struct ResponseKey {
            static let symbol = "01. symbol"
            static let open = "02. open"
            static let high = "03. high"
            static let low = "04. low"
            static let price = "05. price"
            static let volume = "06. volume"
            static let latestTradingDay = "07. latest trading day"
            static let previousClose = "08. previous close"
            static let change = "09. change"
            static let changePercent = "10. change percent"
        }
    }
}
