//
//  SearchViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit
class SearchViewController : UITableViewController {
    

    var papelArray : [PaperStruct]!
    var filteredPapelArray : [PaperStruct]!
    
    var papelDetails : PaperStruct!

    var searchController : UISearchController!
    var operation : String = "default"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if papelArray == nil { papelArray = [] }
        filteredPapelArray = papelArray
		tableView.dataSource = self
		tableView.delegate = self
		configureSearchController()
        definesPresentationContext = true
        print("operation =  \(operation)")
    }
    
	func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
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
        if segue.identifier == "SearchToDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.paperStruct = sender as! PaperStruct
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
        if indexPath == tableView.indexPathForSelectedRow {
            //TODO: desmarcar celula
        }
        
        //TODO: pegar symbol e pesquizar Cotação
        let paper = filteredPapelArray[indexPath.row]
        
        //let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        //detailVC.paperStruct = paper
        
        //self.navigationController?.pushViewController(detailVC, animated: true)
        
        performSegue(withIdentifier: "SearchToDetail", sender: paper)
        
//        AlphaVantageClient.sharedInstance.requestQuote(symbol: paper.symbol) { (globalQuote, error) in
//            guard error == nil else {
//                fatalError("Erro ao aobter cotação: \(error?.localizedDescription)")
//            }
//
//            let quote = Quote(context: DataController.sharedInstance().viewContext)
//
//
//        }
        
        
        //TODO: instanciar Detail
        //TODO: injetar paper e quote em Detail
        //TODO: Navejar até detail.
        
        
        
//        if tableView == resultsController.tableView{
//            userDetails = foundUsers[indexPath.row]
//            self.performSegue(withIdentifier: "PushDetailsVC", sender: self)
//        }
    }
    
    
}
