//
//  PortfolioViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 21/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit
import CoreData

class PortfolioViewController: PaperViewController {
    override var predicate: NSPredicate! { get {return Constants.Predicate.isPortfolio} }
    override var reusableCell: String! {get {return Constants.ReusableCell.portfolioCell}}

    //MARK: Life's cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        autoRequestQuote(interval: 60, requestsPerInterval: 1)
    }

    //MARK: Actions
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        if PortfolioViewController.limitOfPapersReached(with: predicate) {
            Alerts.message(view: self, title: "Alert!", message: "Limit of papers in portfolio just was reached!")
            return
        }
        let tradeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllerId.tradeViewController) as! TradeViewController
        tradeViewController.operation = Trade.OperationType.purchase
        
        present(tradeViewController, animated: true, completion: nil)
    }
    
    //MARK: Api Request
    func autoRequestQuote(interval:TimeInterval = 60, requestsPerInterval : Int = 1) {
        
        guard requestsPerInterval > 0 else { return }
        
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "quoteDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard let result = try? DataController.sharedInstance().backgroundContext.fetch(fetchRequest), result.count > 0 else {
            return
        }
        
        for index in 0...(requestsPerInterval-1) {
            let paper = result[index]
            
            AlphaVantageClient.requestQuote(symbol: paper.symbol!) { (success, globalQuote, error) in
                guard success else {
                    let message = Errors.getDefaultDescription(errorCode:  Errors.ErrorCode(rawValue: (error?.code)!)!)
                    print(message)
                    return
                }
                
                guard globalQuote != nil else{
                    print ("This paper have no quote!")
                    return
                }
                
                self.setQuote(paper, globalQuote)
                
                DispatchQueue.main.async {
                    try? DataController.sharedInstance().backgroundContext.save()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoRequestQuote(interval: interval, requestsPerInterval: requestsPerInterval)
        }
    }
    
    //MARK: Helpers
    func setQuote(_ paper: Paper, _ globalQuote: GlobalQuote!) {
        print("PORTFOLIO - setando autoRequestQuoter...")
        paper.quote?.change = (globalQuote?.change)!
        paper.quote?.changePercent = globalQuote?.changePercent
        paper.quote?.high = (globalQuote?.high)!
        paper.quote?.latest = Utilities.Convert.stringToDate((globalQuote?.latestTradingDay)!, dateFormat: "yyyy-MM-dd")
        paper.quote?.low = (globalQuote?.low)!
        paper.quote?.open = (globalQuote?.open)!
        paper.quote?.previousClose = (globalQuote?.previousClose)!
        paper.quote?.price = (globalQuote?.price)!
        paper.quote?.volume = (globalQuote?.volume)!
        paper.quoteDate = Date()
        print("\(paper.symbol ?? "without symbol") - \(paper.quoteDate ?? "without quote")")
        print("Portifolio - autoRequestQuoter setado!")
    }
}


