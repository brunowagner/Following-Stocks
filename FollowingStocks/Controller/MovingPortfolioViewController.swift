//
//  MovingPortfolioViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 25/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class MovingPortfolioViewController: UIViewController {

    var paper: Paper!
    
    var trade: Trade!
    
    @IBOutlet weak var paperTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trade = Trade(context: DataController.sharedInstance().viewContext)
        
        trade.date = Date()
        trade.operation = "purchase"
        trade.price = 0//(paper?.quote?.price)!
        trade.quantity = Int16((quantityTextField.text! as NSString).intValue)
        
        paperTextField.text = paper?.symbol
        quantityTextField.text = "\(trade.quantity)"
        priceTextField.text = "\(trade.price)"
        dateTextField.text = dateFormatter.string(from: trade.date!)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    @IBAction func searchAction(_ sender: Any) {
        performSegue(withIdentifier: "MovingYourPortifolioToSearch", sender: nil)
    }
    
    @IBAction func unwindToMovingPortfolioViewController(_ sender: UIStoryboardSegue) {
        // created to use um unwind SearchViewController
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction (_ sender: UIButton){
        //paper.addToTrades(trade)
        trade.paper = paper
        print(trade)

        paper.isPortfolio = true
        print(paper)
        do{
            try DataController.sharedInstance().viewContext.save()
            dismiss(animated: true, completion: nil)
        } catch {
            fatalError("Não foi possivel salva no core data")
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchVC = segue.destination as? SearchViewController{
            searchVC.isToFillField = true
        }
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
