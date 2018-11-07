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
    
    //MARK: Properties
//    var fetchedResultsController : NSFetchedResultsController<Paper>!
//    static let limitOfPapers : Int = 5
    override var predicate: NSPredicate! { get {return NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))} }
    override var tableViewCellId: String! {get {return "PortfolioCell"}}
    
    //MARK: Outlets
//    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Life's cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
//        tableView.dataSource = self
//        tableView.delegate = self
        autoRequestQuote(interval: 60, requestsPerInterval: 1)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("\(type(of: self)) - viewWillAppear")
//        setupPaperFetchedResultsController()
//        tableView.reloadData()
//    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("\(type(of: self)) - viewDidDisappear")
//        fetchedResultsController = nil
//    }
    
//    //MARK: Fetcheds
//    fileprivate func setupPaperFetchedResultsController() {
//        print("Iniciando Fetched...")
//        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
//        let predicate = NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))
//        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: true)
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)//"paperFRC")
//        fetchedResultsController.delegate = self
//        
//        do{
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("Can not to do fetchedResultsController.performFetch!")
//        }
//    }
    
    //MARK: Statics Functions
//    static func getPapersCount() -> Int {
//        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
//        let predicate = NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))
//        fetchRequest.predicate = predicate
//
//        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
//            return result.count
//        } else {
//            return 0
//        }
//    }
    
//    static func limitOfPapersReached() -> Bool {
//        let numOfPapers : Int = self.getPapersCount()
//
//        if numOfPapers >= limitOfPapers {
//            return true
//        } else {
//            return false
//        }
//    }
    
    //MARK: Actions
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        if PortfolioViewController.limitOfPapersReached() {
            Alerts.message(view: self, title: "Alert!", message: "Limit of papers in portfolio just was reached!")
            return
        }
        let m = self.storyboard?.instantiateViewController(withIdentifier: "TradeViewController") as! TradeViewController
        m.operation = Trade.OperationType.purchase
        
        present(m, animated: true, completion: nil)
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
    
    //MARK: Helpers and substractions
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
        print("\(paper.symbol) - \(paper.quoteDate)")
        print("Portifolio - autoRequestQuoter setado!")
    }
    
    //TODO: Remove this function
//    func showLoadingIndicator (_ show : Bool ){
//        performUIUpdatesOnMain {
//            if show{
//                LoadingOverlay.shared.showOverlay(view: self.view)
//            }else{
//                LoadingOverlay.shared.hideOverlayView()
//            }
//        }
//    }
}

//// MARK: - UITableViewDataSource
//extension PortfolioViewController: UITableViewDataSource{
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return fetchedResultsController.sections?.count ?? 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCell", for: indexPath) as! PortfolioCell
//        let paper = fetchedResultsController.object(at: indexPath)
//        cell.setFieldsBy(paper: paper)
//        return cell
//    }
//}
//
////MARK: - UITableViewDelegate
//extension PortfolioViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: false)
//
//        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController2") as! DetailViewController2
//        detailVC.paper = fetchedResultsController.object(at: indexPath)
//        self.navigationController?.pushViewController(detailVC, animated: true)
//    }
//}
//
//// MARK: - NSFetchedResultsControllerDelegate
//extension PortfolioViewController: NSFetchedResultsControllerDelegate{
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        switch type {
//        case .insert:
//            print("FRC type = insert")
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//            break
//        case .delete:
//            print("FRC type = delete")
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            break
//        case .update:
//            print("FRC type = update")
//            tableView.reloadData()
//            break
//        case .move:
//            print("FRC type = move")
//            //move isn't applied in this app
//            break
//        }
//    }
//}
