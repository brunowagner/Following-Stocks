//
//  SearchTableViewCell.swift
//  FollowingStocks
//
//  Created by Bruno W on 19/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var symbolLable : UILabel!
    
    @IBOutlet weak var nameLable : UILabel!
    
    @IBOutlet weak var exchangeLable : UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        symbolLable.layer.masksToBounds = true
        symbolLable.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
