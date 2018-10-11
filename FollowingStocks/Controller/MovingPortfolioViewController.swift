//
//  MovingPortfolioViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 25/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class MovingPortfolioViewController: UIViewController {

    //MARK: Properties
    var paper: Paper!
    var quote: Quote!
    var trade: Trade!
    var operation: Trade.OperationType!
    
    //MARK: Outlets
    @IBOutlet weak var paperTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var stepper: UIStepper!

    
    //MARK: Life`s cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        
        quantityTextField.isEnabled = false
        fillUI()
        // Do any additional setup after loading the view.
    }
    
    func fillUI(){
        paperTextField.text = paper?.symbol
        quantityTextField.text = "0"
        priceTextField.text = "\((paper?.quote?.price) ?? 0)"
        dateTextField.text = dateFormatter.string(from: Date())
        self.tradeButton.setTitle(operation.rawValue, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(type(of: self)) - viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(type(of: self)) - viewDidDisappear")
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
         print("\(type(of: self)) - performSegue")
        performSegue(withIdentifier: "MovingYourPortifolioToSearch", sender: nil)
    }
    
    @IBAction func stepperValueChange(_ sender: UIStepper) {
        quantityTextField.text = Int(sender.value).description
    }
    
    
    @IBAction func unwindToMovingPortfolioViewController(_ sender: UIStoryboardSegue) {
        print("\(type(of: self)) - unwindToMovingPortfolioViewController")
        let vc = sender.source as! SearchViewController
        paper = vc.paper
        self.paperTextField.text = paper.symbol
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        print("\(type(of: self)) - cancelAction")
        if paper != nil, !paper.isPortfolio && !paper.isFollowed {
            DataController.sharedInstance().viewContext.delete(paper)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tradeAction (_ sender: UIButton){
        let quantidade = Int16((quantityTextField.text! as NSString).intValue)
        let price = (self.priceTextField.text! as NSString).doubleValue
        
        
        switch operation! {
        case .sale:
            if quantidade == paper.quantity{
                DataController.sharedInstance().viewContext.delete(paper)
                dismiss(animated: true, completion: nil)
                return
            } else {
                paper.quantity -= quantidade
            }
            break
  
        case .purchase:
            paper.averageCost = averageCost(quantityA: paper.quantity, costA: paper.averageCost, quantityB: quantidade, costB: price)
            paper.quantity += quantidade
            paper.isPortfolio = true
        }

        trade = Trade(context: DataController.sharedInstance().viewContext)
        trade.date = dateFormatter.date(from: self.dateTextField.text!)
        trade.operation = operation.rawValue
        trade.price = price
        trade.quantity = quantidade

        trade.paper = paper

        print(trade)

        print(paper)

        do{
            try DataController.sharedInstance().viewContext.save()
            dismiss(animated: true, completion: nil)
        } catch {
            fatalError("Não foi possivel salva no core data")
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\(type(of: self)) - prepareforSegue")
        if let searchVC = segue.destination as? SearchViewController{
            searchVC.isToFillField = true
        }
    }
    
    func averageCost(quantityA : Int16, costA: Double, quantityB: Int16, costB: Double) -> Double{
        let response = (( Double(quantityA) * costA) + (Double(quantityB) * costB)) / ( Double(quantityA) + Double(quantityB))
        return response
    }

}
