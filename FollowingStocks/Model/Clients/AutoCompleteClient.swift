//
//  Autocomplete.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
class AutoCompleteCliente {

// Decidi deixar em arquivo diferente (PaperStruct)
    
//    struct PaperStruct {
//        let symbol: String //: "PBR",
//        let companyName: String  //: "Petróleo Brasileiro S.A. - Petrobras",
//        let exch: String  //: "NYQ",
//        let type: String  //: "S",
//        let exchDisp: String  //: "NYSE",
//        let typeDisp: String  //: "Equity"
//
//        init(dicPaper: [String: AnyObject]) {
//            self.symbol = dicPaper["symbol"] as! String
//            self.companyName = dicPaper["name"] as! String
//            self.exch = dicPaper["exch"] as! String
//            self.type = dicPaper["type"] as! String
//            self.exchDisp = dicPaper["exchDisp"] as! String
//            self.typeDisp = dicPaper["typeDisp"] as! String
//        }
//
//        static func parseToPapelArray(from resultSet: [String : AnyObject]) -> [PaperStruct]{
//            guard let rs = resultSet["ResultSet"] as? [String : AnyObject] else {
//                fatalError("Não foi encontrado 'ResultSet nos dados baixados.'")
//            }
//
//            guard let results = rs["Result"] as? [[String :AnyObject]] else {
//                fatalError("Não foi encontrado 'Result nos dados baixados.'")
//            }
//
//            var papelArray : [PaperStruct] = []
//
//            for data in results {
//                let papel = PaperStruct(dicPaper: data)
//                papelArray.append(papel)
//            }
//            return papelArray
//        }
//    }
//
}



//class Autocomplete {
//
//    //http://autoc.finance.yahoo.com/autoc?query=Brasileiro&region=EU&lang=en-GB
//
//    func find(query: String, region : String, lang: String) -> Dictionary<String, Any> {
//
//        let parameters: [String : AnyObject] = [
//            "query" : query as AnyObject,
//            "region" : region as AnyObject,
//            "lang" : lang as AnyObject
//        ]
//        
//
//        HTTPTools.taskForGETMethod(<#T##method: String##String#>, parameters: parameters, apiRequirements: <#T##ApiRequirements#>, completionHandlerForGET: <#T##(AnyObject?, NSError?) -> Void#>)
//    }
//
//    return [ String : Any]
//}
