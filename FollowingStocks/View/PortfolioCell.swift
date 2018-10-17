//
//  PortfolioCell.swift
//  FollowingStocks
//
//  Created by Bruno W on 21/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class PortfolioCell: UITableViewCell {
    
    @IBOutlet weak var symbol : UILabel!
    @IBOutlet weak var price : UILabel!
    @IBOutlet weak var exchange : UILabel!
    @IBOutlet weak var change : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func setFieldsBy(paper: Paper){
        setSymbol(symbol: paper.symbol)
        setExchange(exchange: paper.exchange, exchangeDisp: paper.exchDisp)
        setPrice(price: paper.quote?.price)
        setChange(value: paper.quote?.change ?? 0, percent: paper.quote?.changePercent ?? "0%")
    }

    func setChange(value: Double, percent: String){
        let changeAttributedText = NSMutableAttributedString(string: String(value) + " (" + percent + ")")
        changeAttributedText.setColorForRacionalNumber(positiveColor: UIColor(named: "DarkGreen")!, negativeColor: UIColor.red)
        
        change.attributedText = changeAttributedText
//        change.text = String(value) + " (" + percent + ")"
//        if value > 0 {
//            change.textColor = UIColor(named: "DarkGreen")
//        } else {
//            change.textColor = UIColor.red
//        }
    }
    
    func setExchange(exchange: String!, exchangeDisp: String!){
        if exchange != nil, exchangeDisp != nil{
            self.exchange.text = exchange + " - " + exchangeDisp
        } else {
            self.exchange.text = "---"
        }
    }
    
    func setSymbol(symbol: String!){
        self.symbol.text = symbol
    }
    
    func setPrice(price: Double!){
        self.price.text = String(format: "%.02f", price ?? 0) //"\(price ?? 0)"
    }
}
