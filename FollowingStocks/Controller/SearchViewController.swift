//
//  SearchViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class SearchViewController : UITableViewController {
    
    //MARK: Properties
    var paper: Paper!
    var paperArray : [PaperStruct]!
    var filteredPaperArray : [PaperStruct]!
    var searchController : UISearchController!
    var isToFillField : Bool = false
    
    //MARK: Life`s Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        initiateArrays()
        configureTableView()
        configureSearchController()
        definesPresentationContext = true
        print("toFillField =  \(isToFillField)")
    }
    
    //MARK: API Request
    func requestDataFromServer (query : String){
        AutoCompleteCliente.requestPaper(query: query){ (success, data, error) in
            if success {
                self.reloadTabel(data: data!)
            }
        }
    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        setPaper(paperStruct: sender as! PaperStruct)
        
        if segue.identifier == Constants.SegueId.searchToDetail2 {
            let detailVC = segue.destination as! DetailViewController2
            detailVC.paper = paper
        }
        if segue.identifier ==  Constants.SegueId.unwindToMovingPortfolioViewController {
            let mVC = segue.destination as! TradeViewController
            mVC.paper = paper
        }
    }
    
    //MARK: Helpers
    func initiateArrays(){
        if paperArray == nil { paperArray = [] }
        filteredPaperArray = paperArray
    }
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        if isToFillField { searchController.searchBar.setShowsCancelButton(true, animated: true) }
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setPaper(paperStruct : PaperStruct){
        if let result = fetchPaper(symbol: paperStruct.symbol) {
            paper = result
        } else {
            paper = Paper(context: DataController.sharedInstance().viewContext)
            paper.symbol = paperStruct.symbol
            paper.name = paperStruct.companyName
            paper.exchange = paperStruct.exch
            paper.exchDisp = paperStruct.exchDisp
            paper.type = paperStruct.type
            paper.typeDisp = paperStruct.typeDisp
        }
    }
    
    func fetchPaper(symbol : String) -> Paper?{
        let fetch : NSFetchRequest<Paper> = Paper.fetchRequest()
        
        let predicate : NSPredicate = NSPredicate(format: Constants.PredicateFormat.symbol, symbol)
        fetch.predicate = predicate
        
        if let results = try? DataController.sharedInstance().viewContext.fetch(fetch), results.count > 0 {
            return results[0]
        } else {
            return nil
        }
    }
    
    func reloadTabel(data : [String : AnyObject]) {
        DispatchQueue.main.async {
            self.filteredPaperArray = PaperStruct.parseToPapelArray(from: data)
            self.tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPaperArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReusableCell.searchCell) as! SearchTableViewCell
        
        let paper : PaperStruct = filteredPaperArray[indexPath.row]
        print(paper.symbol)
        
        cell.symbolLable.text = paper.symbol
        cell.nameLable.text = paper.companyName
        cell.exchangeLable.text = paper.exch + " - " + paper.exchDisp
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // paadicionadora add
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard isToFillField == false else {
            dismiss(animated: false, completion: nil)
            return performSegue(withIdentifier: Constants.SegueId.unwindToMovingPortfolioViewController, sender: filteredPaperArray[indexPath.row])
        }
        
        let paper = filteredPaperArray[indexPath.row]
        performSegue(withIdentifier: Constants.SegueId.searchToDetail2, sender: paper)
    }
}

//MARK: - UISearchResultsUpdating
extension SearchViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.isEmpty {
                filteredPaperArray = paperArray
            } else {
                requestDataFromServer(query : searchText)
            }
            tableView.reloadData()
        }
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController : UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isToFillField  {
            dismiss(animated: true, completion: nil)
        }
    }
}
