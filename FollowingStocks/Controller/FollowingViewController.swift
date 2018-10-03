//
//  FollowingViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 19/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController {

    @IBOutlet weak var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnAction(_ sender: Any) {
        //self.tabBarController?.tabBar.isHidden = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
