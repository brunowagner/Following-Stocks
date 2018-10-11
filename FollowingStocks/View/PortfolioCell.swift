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

    func setChange(value: Double, percent: String){
        change.text = String(value) + " (" + percent + ")"
        if value > 0 {
            change.textColor = UIColor(named: "DarkGreen")
        } else {
            change.textColor = UIColor.red
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
