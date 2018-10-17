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
    
    var paper: Paper!
    var papelArray : [PaperStruct]!
    var filteredPapelArray : [PaperStruct]!
    
    //var papelDetails : PaperStruct!

    var searchController : UISearchController!
    var isToFillField : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        if papelArray == nil { papelArray = [] }
        filteredPapelArray = papelArray
		tableView.dataSource = self
		tableView.delegate = self
		configureSearchController()
        definesPresentationContext = true
        print("toFillField =  \(isToFillField)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(SearchViewController.self) - viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(SearchViewController.self) - viewWillDisappear")
        
        
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
	
    func requestDataFromServer(query : String){
        
        let parameters = [
            "query" : query,
            "region" : "1",
            "lang" : "en"
            ] as [String: AnyObject]
        
        let _ = HTTPTools.taskForGETMethod("", parameters: parameters, apiRequirements: AutocompleteApiRequirements()) { (data, error) in
            guard error == nil else{
                fatalError("vouve um erro ao baixar os dados : " + (error?.localizedDescription)!)
            }
            print(data!)
            
            //self.filteredPapelArray = paperStruct.parseToPapelArray(from: data as! [String : AnyObject])
            
            DispatchQueue.main.async {
                self.filteredPapelArray = PaperStruct.parseToPapelArray(from: data as! [String : AnyObject])
                self.tableView.reloadData()
            }
        }
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        generatePaper(paperStruct: sender as! PaperStruct)
        
        if segue.identifier == "SearchToDetail2" {
            let detailVC = segue.destination as! DetailViewController2
            //detailVC.paperStruct = sender as! PaperStruct
            detailVC.paper = paper
        }
        if segue.identifier == "unwindToMovingPortfolioViewController"{
            let mVC = segue.destination as! MovingPortfolioViewController
            //let paperStruct = sender as! PaperStruct
            //mVC.paperTextField.text = paperStruct.symbol
            mVC.paper = paper
        }
    }
    
    func generatePaper(paperStruct : PaperStruct){
        
        // verifica se papel ja existe (no portfolio), caso sim: retornar o já existente
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
        let predicate : NSPredicate = NSPredicate(format: "symbol == %@", symbol)
        fetch.predicate = predicate
        
        if let results = try? DataController.sharedInstance().viewContext.fetch(fetch), results.count > 0 {
             return results[0]
        } else {
            return nil
        }
    }
}

//MARK: UITableViewDataSource
extension SearchViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPapelArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchTableViewCell
        
        let paper : PaperStruct = filteredPapelArray[indexPath.row]
        print(paper.symbol)

        cell.symbolLable.text = paper.symbol
        cell.nameLable.text = paper.companyName
        cell.exchangeLable.text = paper.exch + " - " + paper.exchDisp

        return cell
    }
}

extension SearchViewController : UISearchResultsUpdating {
    
	func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.isEmpty {
                filteredPapelArray = papelArray
            } else {
                requestDataFromServer(query : searchText)
            }
            tableView.reloadData()
        }
	}
} 

//MARK: UITableViewDelegate
extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    //adicionado para add
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard isToFillField == false else {
            
             dismiss(animated: false, completion: nil)
             return performSegue(withIdentifier: "unwindToMovingPortfolioViewController", sender: filteredPapelArray[indexPath.row])
        }
        let paper = filteredPapelArray[indexPath.row]
        performSegue(withIdentifier: "SearchToDetail2", sender: paper)

    }
    
    
}

extension SearchViewController : UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isToFillField  {
            dismiss(animated: true, completion: nil)
        }
    }
}
