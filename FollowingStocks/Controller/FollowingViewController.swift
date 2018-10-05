//
//  FollowingViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 19/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit
import CoreData

class FollowingViewController: UIViewController {

    var fetchedResultsController : NSFetchedResultsController<Paper>!
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Life's cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(type(of: self)) - viewDidLoad")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(type(of: self)) - viewWillAppear")
        setupPaperFetchedResultsController()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(type(of: self)) - viewDidDisappear")
        fetchedResultsController = nil
    }
    
    //MARK: Fetcheds
    
    fileprivate func setupPaperFetchedResultsController() {
        print("Iniciando Fetched...")
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        
        let predicate = NSPredicate(format: "isFollowed == %@", NSNumber(value: true))
        
        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: true)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //------------ apenas para testar o fetchRequst puro
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            let papers : [Paper] = result
            
            //for p in papers{
            //    print(p.symbol)
            //}
            
            print(papers.count)
            //print(papers)
        }
        //----------
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)//"paperFRC")
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Can not to do fetchedResultsController.performFetch!")
        }
        print("Quantidade objetos no fetched: \(String(describing: fetchedResultsController.sections?[0].numberOfObjects))")
    }
}


// MARK: UITableViewDataSource
extension FollowingViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! PortfolioCell
        
        let paper = fetchedResultsController.object(at: indexPath)
        
        cell.symbol.text = paper.symbol
        cell.exchange.text = paper.exchange
        cell.price.text = "\(paper.quote?.price ?? 0)"
        cell.change.text = "\(paper.quote?.change ?? 0)"
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension FollowingViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        //TODO: pegar symbol e pesquizar Cotação
        //let paper = fetchedResultsController.object(at: indexPath)
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.paper = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}



// MARK: - NSFetchedResultsControllerDelegate
extension FollowingViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        switch type {
        case .insert:
            print("FRC type = insert")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            print("FRC type = delete")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            print("FRC type = update")
            tableView.reloadData()
            break
        case .move:
            print("FRC type = move")
            //move isn't applied in this app
            break
        }
    }

}
