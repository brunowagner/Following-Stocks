//
//  paperStruct.swift
//  FollowingStocks
//
//  Created by Bruno W on 26/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation

struct PaperStruct {
    let symbol: String //: "PBR",
    let companyName: String  //: "Petróleo Brasileiro S.A. - Petrobras",
    let exch: String  //: "NYQ",
    let type: String  //: "S",
    let exchDisp: String  //: "NYSE",
    let typeDisp: String  //: "Equity"

    init(dicPaper: [String: AnyObject]) {
        self.symbol = dicPaper[Constants.AutoComplete.ResponseKey.symbol] as! String
        self.companyName = dicPaper[Constants.AutoComplete.ResponseKey.name] as! String
        self.exch = dicPaper[Constants.AutoComplete.ResponseKey.exch] as! String
        self.type = dicPaper[Constants.AutoComplete.ResponseKey.type] as! String
        self.exchDisp = dicPaper[Constants.AutoComplete.ResponseKey.exchDisp] as! String
        self.typeDisp = dicPaper[Constants.AutoComplete.ResponseKey.typeDisp] as! String
    }

    static func parseToPapelArray(from resultSet: [String : AnyObject]) -> [PaperStruct]{
        guard let rs = resultSet["ResultSet"] as? [String : AnyObject] else {
            fatalError("'ResultSet'' not finded in download data!")
        }

        guard let results = rs["Result"] as? [[String :AnyObject]] else {
            fatalError("'ResultSet'' not finded in download data!")
        }

        var paperArray : [PaperStruct] = []

        for data in results {
            let paper = PaperStruct(dicPaper: data)
            paperArray.append(paper)
        }
        return paperArray
    }
}
