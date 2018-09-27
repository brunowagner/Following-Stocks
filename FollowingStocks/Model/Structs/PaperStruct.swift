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
        self.symbol = dicPaper["symbol"] as! String
        self.companyName = dicPaper["name"] as! String
        self.exch = dicPaper["exch"] as! String
        self.type = dicPaper["type"] as! String
        self.exchDisp = dicPaper["exchDisp"] as! String
        self.typeDisp = dicPaper["typeDisp"] as! String
    }
    
    static func parseToPapelArray(from resultSet: [String : AnyObject]) -> [PaperStruct]{
        guard let rs = resultSet["ResultSet"] as? [String : AnyObject] else {
            fatalError("Não foi encontrado 'ResultSet nos dados baixados.'")
        }
        
        guard let results = rs["Result"] as? [[String :AnyObject]] else {
            fatalError("Não foi encontrado 'Result nos dados baixados.'")
        }
        
        var papelArray : [PaperStruct] = []
        
        for data in results {
            let papel = PaperStruct(dicPaper: data)
            papelArray.append(papel)
        }
        return papelArray
    }
}
