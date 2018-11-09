//
//  FollowingViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 19/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit
import CoreData

class FollowingViewController: PaperViewController {
    override var predicate: NSPredicate! { get {return Constants.Predicate.isFollowing} }
    override var reusableCell: String! {get {return Constants.ReusableCell.followingCell} }
}
