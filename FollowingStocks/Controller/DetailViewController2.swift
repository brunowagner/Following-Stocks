//
//  DetailViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 24/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class DetailViewController2: UIViewController {
    
    //MARK: Properties
    var paper : Paper!
    var quote : Quote!
    
    //MARK: Outlets
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTypeExchangeExchangeDisp: UILabel!
    @IBOutlet weak var labelSymbol: UILabel!
    @IBOutlet weak var labelprice: UILabel!
    @IBOutlet weak var labelchange: UILabel!
    @IBOutlet weak var labelchangePercent: UILabel!
    @IBOutlet weak var labelPreviousClose: UILabel!
    @IBOutlet weak var labelOpen: UILabel!
    @IBOutlet weak var labelHigh: UILabel!
    @IBOutlet weak var labelLow: UILabel!
    @IBOutlet weak var labelVolume: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var labelAveragePrice: UILabel!
    @IBOutlet weak var labelLatestTradingDay: UILabel!
    @IBOutlet weak var followButton: UIBarButtonItem!
    @IBOutlet weak var portfolioButton: UIBarButtonItem!
    @IBOutlet weak var viewSymbol: UIView!
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var stackViewPortfolio: UIStackView!
    
    //MARK: Life`s Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        self.initializeQuote()
        self.loadPaperInUI()
        self.configureBorders()
        self.requestQuote(symbol: paper.symbol!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(type(of: self)) - viewWillAppear")
        self.showTabBar(option: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(type(of: self)) - viewWillDisappear")
        self.showTabBar(option: false)
        self.clearManagedObjectsFromMemory()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.configureBorders()
    }

    //MARK: Actions
    @IBAction func portfolioAction(_ sender: Any) {
        print("presentPortfolioTradeAlert - inicio")
        presentPortfolioTradeAlert()
        print("presentPortfolioTradeAlert - fim")
    }
    
    @IBAction func followingAction(_ sender: Any) {
        if !isPaperFollowed(), FollowingViewController.limitOfPapersReached(with: Constants.Predicate.isFollowing) {
            Alerts.message(view: self, title: "Alert!", message: "Limit of papers in following just was reached!")
            
        } else {
            paper.isFollowed = !paper.isFollowed
            do {
                try DataController.sharedInstance().viewContext.save()
                self.toggleUIFollowingButton(to: isPaperFollowed())
                if isPaperFollowed() {
                    Alerts.toast(view: self, message: "Following Paper!", speed: .medium, completion: nil)
                } else {
                    Alerts.toast(view: self, message: "Does not Following Paper!", speed: .medium, completion: nil)
                }
            } catch {
                Alerts.message(view: self, title: "Can't following paper!", message: "\nAn unknown error occurred!")
            }
        }
    }

    @IBAction func unwindToDetail(_ sender: UIStoryboardSegue) {
        //usado para recarregar a quantidade de ações após fazer trade.
        loadPaperInUI()
    }
    
    //MARK: Portifolio
    func presentPortfolioTradeAlert() {
        let alert = UIAlertController(title: "Portfolio Trade", message: "What trade do you might?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let add = UIAlertAction(title: "Purchase (add)", style: .default) { (alertAction) in
            self.tradePaper(operation: .purchase)
        }
        let remove = UIAlertAction(title: "Sale (remove)", style: .default) { (alertAcion) in
            self.tradePaper(operation: .sale)
        }
        alert.addAction(cancel)
        alert.addAction(remove)
        alert.addAction(add)
        
        remove.isEnabled = isPaperPortfolio()
        
        present(alert, animated: true, completion: nil)
    }
    
    func tradePaper(operation: Trade.OperationType){
        if !isPaperPortfolio(), PortfolioViewController.limitOfPapersReached(with: Constants.Predicate.isPortfolio) {
            Alerts.message(view: self, title: "Alert!", message: "Limit of papers in portfolio just was reached!")
            return
        }
        
        let tradeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllerId.tradeViewController) as! TradeViewController
        
        print("DETAIL - injetando paper...")
        tradeViewController.paper = paper
        tradeViewController.operation = operation
        tradeViewController.accessedBy = self
        print("DETAIL - paper injetado!")
        
        present(tradeViewController, animated: true, completion: nil)
    }
    
    //MARK: UI
    func toggleUIFollowingButton (to on: Bool){
        let namedImage = on ? Constants.ImageName.following : Constants.ImageName.unfollowing
        followButton.image = UIImage(named: namedImage)
    }
    
    func loadPaperInUI(){
        self.labelName.text = paper.name
        self.labelSymbol.text = paper.symbol
        self.labelTypeExchangeExchangeDisp.text = "\(paper.type ?? "") - \(paper.exchange ?? "") - \(paper.exchDisp ?? "")"
        
        if isPaperPortfolio(){
            self.labelQuantity.text = "\(paper.quantity)"
            self.labelAveragePrice.text = String(format: "%.02f",paper.averageCost)
            stackViewPortfolio.isHidden = false
        } else {
            stackViewPortfolio.isHidden = true
        }
        self.toggleUIFollowingButton(to: isPaperFollowed())
    }
    
    func loadStorageData(){
        if isPaperStoraged(){
            performUIUpdatesOnMain {
                print(self.quote)
                let globalQuote = GlobalQuote(quote: self.quote)
                self.loadQuoteInUI(globalQuote: globalQuote)
            }
        }
    }
    
    func loadQuoteInUI(globalQuote: GlobalQuote){
        let changeAttributedText = NSMutableAttributedString(string: String(globalQuote.change))
        changeAttributedText.setColorForRacionalNumber(positiveColor: UIColor(named: Constants.CollorName.darkGreen)!, negativeColor: UIColor.red)
        let changePercentAttributedText = NSMutableAttributedString(string: "(\(globalQuote.changePercent))")
        changePercentAttributedText.setColorForRacionalNumber(positiveColor: UIColor(named: Constants.CollorName.darkGreen)!, negativeColor: UIColor.red)
        
        self.labelprice.text =  String(format: "%.02f", globalQuote.price )
        self.labelchange.attributedText = changeAttributedText
        self.labelchangePercent.attributedText = changePercentAttributedText
        self.labelHigh.text = String(format: "%.02f", globalQuote.high )
        self.labelLatestTradingDay.text =  "\(globalQuote.latestTradingDay)"
        self.labelLow.text = String(format: "%.02f", globalQuote.low )
        self.labelOpen.text = String(format: "%.02f", globalQuote.open )
        self.labelPreviousClose.text = String(format: "%.02f", globalQuote.previousClose )
        self.labelVolume.text = "\(globalQuote.volume)"
        
        self.toggleUIFollowingButton(to: isPaperFollowed())
        
        if isPaperPortfolio(){
            try? DataController.sharedInstance().viewContext.save()
        }
    }
    
    func configureBorders(){
        DispatchQueue.main.async {
            self.viewSymbol.layer.borderWidth = 1
            self.viewSymbol.layer.borderColor = UIColor.lightGray.cgColor
            
            self.viewPrice.layer.borderWidth = 1
            self.viewPrice.layer.borderColor = UIColor.lightGray.cgColor
            
            self.viewHeader.layer.borderWidth = 1
            self.viewHeader.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func showLoadingIndicator (_ show : Bool ){
        performUIUpdatesOnMain {
            if show{
                LoadingOverlay.shared.showOverlay(view: self.view)
            }else{
                LoadingOverlay.shared.hideOverlayView()
            }
        }
    }
    
    //MARK: API Request
    func requestQuote(symbol : String) {
        showLoadingIndicator(true)
        AlphaVantageClient.requestQuote(symbol: symbol) { (success, globalQuote, error) in
            self.showLoadingIndicator(false)
            if success {
                guard globalQuote != nil else{
                    Alerts.message(view: self, title: "Alert!", message: "This paper have no quote!")
                    return
                }
                self.setQuote(globalQuote: globalQuote)
                DispatchQueue.main.async {
                    self.loadQuoteInUI(globalQuote: globalQuote!)
                }
                
            } else {
                var message = Errors.getDefaultDescription(errorCode:  Errors.ErrorCode(rawValue: (error?.code)!)!)
                if error?.code == Errors.ErrorCode.Limit_of_requests_per_minute_was_exceeded.rawValue {
                    message += "\n\nPlease try again in a few moments."
                }
                message += "\n\nWould you like to see last stored quotation?"
                Alerts.yesNo(view: self, title: "Alert!", message: message, completionHander: { (yes) in
                    if yes {
                        self.loadStorageData()
                    }
                })
            }
        }
    }
    
    //MARK: Helper and abstracting
    fileprivate func initializeQuote() {
        if paper.quote != nil{
            print("DETAIL - criando quote...")
            quote = paper.quote
            print("DETAIL - quote criado!")
        } else {
            quote = Quote(context: DataController.sharedInstance().viewContext)
        }
    }
    
    func isPaperStoraged() -> Bool {
        var returnBool : Bool = false
        if isPaperFollowed() || isPaperPortfolio() {
            returnBool = true
        }
        return returnBool
    }
    
    func isPaperFollowed() -> Bool {
        return paper.isFollowed
    }
    
    func isPaperPortfolio() -> Bool {
        return paper.isPortfolio
    }
    
    fileprivate func showTabBar(option : Bool) {
        self.tabBarController?.tabBar.isHidden = option
    }
    
    fileprivate func clearManagedObjectsFromMemory() {
        if !isPaperStoraged() {
            DataController.sharedInstance().viewContext.delete(paper)
        }
        
        //if paper was deleted in any viewController
        if paper.isDeleted {
            try? DataController.sharedInstance().viewContext.save()
        }
    }
    
    fileprivate func setQuote(globalQuote: GlobalQuote?) {
        print("DETAIL - setando quoter...")
        self.quote.change = (globalQuote?.change)!
        self.quote.changePercent = globalQuote?.changePercent
        self.quote.high = (globalQuote?.high)!
        self.quote.latest = Utilities.Convert.stringToDate((globalQuote?.latestTradingDay)!, dateFormat: "yyyy-MM-dd")
        self.quote.low = (globalQuote?.low)!
        self.quote.open = (globalQuote?.open)!
        self.quote.previousClose = (globalQuote?.previousClose)!
        self.quote.price = (globalQuote?.price)!
        self.quote.volume = (globalQuote?.volume)!
        
        self.quote.paper = self.paper
        print("DETAIL - quoter setado!")
    }
}
