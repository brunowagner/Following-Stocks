//
//  PaperViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 01/11/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit
import CoreData
class PaperViewController: UIViewController {
    
    //MARK: Properties
    var fetchedResultsController : NSFetchedResultsController<Paper>!
    var predicate : NSPredicate! { get {return nil} }
    var reusableCell : String! {get {return nil}}
    static let limitOfPapers : Int = 5
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    //MARK: Life's cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard predicate != nil && reusableCell != nil else {
            fatalError("Override 'predicate' and 'tableViewCellId' variables on format '{get {return ...} }'!")
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPaperFetchedResultsController()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: Fetcheds
    fileprivate func setupPaperFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Can not to do fetchedResultsController.performFetch!")
        }
    }
    
    //MARK: Statics Functions
    static func getPapersCount(with predicate: NSPredicate) -> Int {
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        fetchRequest.predicate = predicate
        
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            return result.count
        } else {
            return 0
        }
    }
    
    static func limitOfPapersReached(with predicate: NSPredicate) -> Bool {
        let numOfPapers : Int = self.getPapersCount(with: predicate)
        
        if numOfPapers >= limitOfPapers {
            return true
        } else {
            return false
        }
    }
}

// MARK: UITableViewDataSource
extension PaperViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCell, for: indexPath) as! PortfolioCell
        let paper = fetchedResultsController.object(at: indexPath)
        cell.setFieldsBy(paper: paper)
        return cell
    }
}

//MARK: UITableViewDelegate
extension PaperViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllerId.detailViewController2) as! DetailViewController2
        detailViewController.paper = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension PaperViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadData()
            break
        case .move:
            //move isn't applied in this app
            break
        }
    }
}
